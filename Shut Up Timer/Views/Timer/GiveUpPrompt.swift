//
//  GiveUpPrompt.swift
//  Shut Up Timer
//
//  Created by Daniel Ye on 2025-08-01.
//

import SwiftUI

struct GiveUpPrompt: View {
    let onNo: () -> Void
    let onYes: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            // Sobbing Grandma positioned above the dialog
            SobbingGrandma(middleView: {
                // Dialog box content goes here as the middle view
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(maxHeight: 20)
                    // Main question text
                    Text("Giving up already?")
                        .font(FontTokens.architectsDaughter(size: 42))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.white)
                    Spacer()
                        .frame(maxHeight: 5)
                    
                    // Subtitle text
                    Text("You'll have a lower IQ...")
                        .font(FontTokens.architectsDaughter(size: 24))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                        .frame(maxHeight: 20)
                    
                    // Buttons
                    HStack(spacing: 20) {
                        // No button
                        Button(action: onNo) {
                            Text("NO")
                                .font(FontTokens.architectsDaughter(size: 36))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ColorTokens.red300)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                )
                        }
                        
                        // Yes button
                        Button(action: onYes) {
                            HStack(spacing: 10) {
                                Text("YES")
                                    .font(FontTokens.architectsDaughter(size: 28))
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("i'll lose")
                                        .font(FontTokens.architectsDaughter(size: 16))
                                        .lineLimit(1)
                                        .foregroundColor(.black)
                                    Text("some IQ")
                                        .font(FontTokens.architectsDaughter(size: 16))
                                        .lineLimit(1)
                                        .foregroundColor(.black)
                                        .padding(.top, -9)
                                }
                            }
                            .padding(.horizontal, 8)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(ColorTokens.shade300)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white, lineWidth: 3)
                                    )
                            )
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorTokens.gray800)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .inset(by: 2)
                                .stroke(Color.white, lineWidth: 4)
                        )
                )
            })
        }
    }
}

struct SobbingGrandma<MiddleView: View>: View {
    let middleView: () -> MiddleView
    
    init(@ViewBuilder middleView: @escaping () -> MiddleView) {
        self.middleView = middleView
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Hand overlay image (you'll add this)
            Group {
                Image(uiImage: ImageAssets.image178)
                    .resizable()
                    .frame(width: 300, height: 300)
                    .offset(x: 60, y: 40)
            }
            .frame(width: 40, height: 50, alignment: .bottomTrailing)
            
            // Middle view (dialog content)
            middleView()
            
            // Hand overlay image (you'll add this)
            Group {
                Image(uiImage: ImageAssets.image179)
                    .resizable()
                    .frame(width: 300, height: 300)
                    .offset(x: 60, y: 40)
            }
            .frame(width: 70, height: 50, alignment: .bottomTrailing)
            .clipped()
        }
        .padding(.top, 200)
        .padding(.trailing, 20)
    }
}

#Preview {
    ZStack {
        Color.black
        GiveUpPrompt(onNo: {}, onYes: {})
    }
}

