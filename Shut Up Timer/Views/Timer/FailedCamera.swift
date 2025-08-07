import SwiftUI;
import CoreData

struct FailedCameraView : View {
    @State private var image: UIImage?;
    @State private var showCamera = false;
    @EnvironmentObject var sessions: SessionLoader;
    @EnvironmentObject var router: AppRouter;
    @Environment(\.managedObjectContext) private var viewContext
    let sessionID: UUID;
    
    var body : some View {
        ZStack {
            Background()
                .overlay(Color.black.opacity(0.3))
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        router.toHome()
                    }) {
                        Text("Skip  >")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .multilineTextAlignment(.center)
                            .foregroundColor(ColorTokens.shade100)
                    }
                    Spacer()
                        .frame(width: 20)
                }
                Text("Face of Disappointment")
                    .font(FontTokens.architectsDaughter(size: 30))
                  .multilineTextAlignment(.center)
                  .foregroundColor(.white)
                  .frame(width: 388, height: 44, alignment: .top)
                
                GeometryReader { geo in
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .overlay(
                                Rectangle()
                                    .inset(by: 2.5)
                                    .stroke(.white, lineWidth: 5)
                            )
                        if let image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        } else {
                            CameraView(image: $image)
                        }
                    }
                }
                .frame(width: 336)
                
                Spacer()
                    .frame(maxHeight: 20)
                
                OnboardingNextButton(text: "Be Ashamed", onSelect: {
                    if let image = image {
                        let imageName: String = UUID().rawValue;
                        let success = ImageLoader.saveImage(name: imageName, image: image)
                        if success {
                            // Find and update the Core Data Session entity
                            let sessionRequest: NSFetchRequest<Session> = Session.fetchRequest()
                            sessionRequest.predicate = NSPredicate(format: "id == %@", sessionID as CVarArg)
                            
                            do {
                                let sessions = try viewContext.fetch(sessionRequest)
                                if let session = sessions.first {
                                    session.imageName = imageName
                                    try viewContext.save()
                                }
                            } catch {
                                print("Failed to update session with image: \(error)")
                            }
                        }
                    }
                    router.toHome()
                })
                Spacer()
                    .frame(maxHeight: 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    FailedCameraView(sessionID: UUID())
        .environmentObject(CredManager(subscriptionManager: SubscriptionManager()))
        .environmentObject(AppRouter())
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
