//
//  AddPostView.swift
//  Shut Up Timer
//
//  Created by Daniel Ye on 2025-07-01.
//

import SwiftUI
import PhotosUI

struct AddPostRawView: View {
    @Binding var text: String
    var images: [UIImage]
    var onSessionTap: () -> Void
    var onSessionRemove: () -> Void
    var onAddImageTap: () -> Void
    var onRemoveImage: (Int) -> Void
    var onPost: () -> Void
    var onClose: () -> Void
    var selectedSession: Session?
    var date: Date?
    var isUploading: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            Background()
            VStack(alignment: .leading, spacing: 0) {
                // Top Bar
                HStack(spacing: 16) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(ColorTokens.shade700)
                    }
                    Spacer()
                    ViewThatFits {
                        Button(action: onSessionTap) {
                            Text("Pick Session")
                                .font(FontTokens.architectsDaughter(size: 18))
                                .foregroundColor(ColorTokens.shade700)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .overlay(
                                    RoundedRectangle(cornerSize: CGSize(width: 14, height: 14))
                                        .stroke(ColorTokens.shade700, lineWidth: 2)
                                )
                        }
                        Button(action: onSessionTap) {
                            Text("Session")
                                .font(FontTokens.architectsDaughter(size: 18))
                                .foregroundColor(ColorTokens.shade700)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .overlay(
                                    RoundedRectangle(cornerSize: CGSize(width: 14, height: 14))
                                        .stroke(ColorTokens.shade700, lineWidth: 2)
                                )
                        }
                    }
                    Spacer()
                    Button(action: onPost) {
                        HStack {
                            if isUploading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Uploading...")
                                    .font(FontTokens.architectsDaughter(size: 22))
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                            } else {
                                Text("Post")
                                    .font(FontTokens.architectsDaughter(size: 22))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(isUploading ? ColorTokens.shade400 : ColorTokens.red300)
                        .cornerRadius(14)
                    }
                    .disabled(isUploading)
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
                
                // TextField
                TextField("Anything to rant about?", text: $text, axis: .vertical)
                    .font(FontTokens.architectsDaughter(size: 22))
                    .frame(minHeight: 200, alignment: .top)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                // Date (if session selected)
                if let date = date {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Current Session:")
                                .font(FontTokens.architectsDaughter(size: 16))
                                .foregroundColor(ColorTokens.shade700)
                                .padding(.trailing, 24)
                            Text(date, formatter: DateFormatter.shortDateTime)
                                .font(FontTokens.architectsDaughter(size: 16))
                                .foregroundColor(ColorTokens.shade700)
                                .padding(.trailing, 24)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                onSessionRemove()
                            } label: {
                                Label("Remove Session", systemImage: "trash")
                            }
                        }
                    }
                }
                
                // Horizontal Images
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(Array(images.enumerated()), id: \ .offset) { idx, img in
                            ZStack(alignment: .topTrailing) {
                                PostImageDisplay(image: img)
                                    .frame(width: 120, height: 120)
                                Button(action: { onRemoveImage(idx) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .offset(x: 10, y: -18)
                            }
                        }
                        // Plus icon
                        Button(action: onAddImageTap) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 141)
                                Image(systemName: "plus")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(ColorTokens.shade700)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }
            }
            .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddPostView: View {
    @EnvironmentObject var sessions: SessionLoader
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var postLoader: PostLoader
    @EnvironmentObject var credManager: CredManager
    @EnvironmentObject var curUser: CurUser
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var text: String = ""
    @State private var images: [UIImage] = []
    @State private var showSessionModal = false
    @State private var showPhotosPicker = false
    @State private var pickedPhoto: PhotosPickerItem? = nil
    @State private var selectedSession: Session? = nil
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    @State private var isUploading = false
    
    // Fetch successful sessions using @FetchRequest for automatic updates
    @FetchRequest(
        entity: Session.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Session.started, ascending: false)],
        predicate: NSPredicate(format: "success == YES")
    ) private var successfulSessions: FetchedResults<Session>

    var body: some View {
        AddPostRawView(
            text: $text,
            images: images,
            onSessionTap: { showSessionModal = true },
            onSessionRemove: { selectedSession = nil},
            onAddImageTap: { showPhotosPicker = true },
            onRemoveImage: { idx in images.remove(at: idx) },
            onPost: handlePost,
            onClose: { appRouter.pop() },
            selectedSession: selectedSession,
            date: selectedSession?.started,
            isUploading: isUploading
        )
        .sheet(isPresented: $showSessionModal) {
            SessionSelectionModal(sessions: Array(successfulSessions), onSelect: { session in
                selectedSession = session
                showSessionModal = false
                // If session has an image, load it
                if let imageName = session.imageName, let img = ImageLoader.loadImage(name: imageName) {
                    images.append(img)
                }
            }, onCancel: { showSessionModal = false })
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $pickedPhoto, matching: .images)
        .onChange(of: pickedPhoto) { newVal in
            guard let newVal else { return }
            Task {
                if let data = try? await newVal.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                    await MainActor.run { images.append(img) }
                }
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    func handlePost() {
        // First save locally (always succeeds)
        let post = postLoader.insertPost(sessionID: selectedSession?.id, text: text, images: images)
        
        // Then attempt to upload to server
        isUploading = true
        Task {
            let postInfo = post.toLocalPostInfo(currentUser: curUser, context: viewContext)
            let remoteId = await credManager.fastAPI.createPost(postInfo)
            
            await MainActor.run {
                isUploading = false
                showAlert = true
                
                if let remoteId = remoteId {
                    // Update the post with the remote ID
                    postLoader.updateRemoteId(post.id, remoteId: remoteId)
                    alertMessage = "Post created and uploaded successfully!"
                } else {
                    alertMessage = "Post saved locally, but failed to upload to server. You can try again later."
                }
                
                // Clear form (post is always saved locally)
                text = ""
                images = []
                selectedSession = nil
            }
        }
    }
}

struct SessionSelectionModal: View {
    var sessions: [Session]
    var onSelect: (Session) -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(sessions, id: \.objectID) { session in
                    Button(action: { onSelect(session) }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(session.started?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown Date")
                                    .font(FontTokens.architectsDaughter(size: 18))
                                    .foregroundColor(ColorTokens.shade700)
                                Text(session.success ? "Success" : "Failed")
                                    .font(FontTokens.architectsDaughter(size: 14))
                                    .foregroundColor(session.success ? .green : .red)
                            }
                            Spacer()
                            if let imageName = session.imageName, let img = ImageLoader.loadImage(name: imageName) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    return AddPostView()
        .environmentObject(SessionLoader())
        .environmentObject(AppRouter())
        .environmentObject(PostLoader.loadPostLoader())
        .environmentObject(CurUser(credManager: CredManager()))
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

