//
//  CreateLogView.swift
//  FitnessSharing
//
//  Created by Krish on 8/21/22.
//

import SwiftUI
import FirebaseFirestore
import UIKit

struct CreateLogView: View {
    
    @Binding var showSheet: Bool
    @Binding var logImage: UIImage
    var target: Target
    @EnvironmentObject var habitat: Habitat
    @State private var isProgress = true
    @State private var difficulty = String()
    @State private var reason = String()
    @State private var currentAmountString = String()
    @State private var hashtag = String()
    @State private var isLogged = false
    
    private let hashtags = ["hittingthetarget", "grindsetmindset", "targetpostworksthemost"]
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    self.showSheet.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray.opacity(0.8))
                        .frame(width: 18, height: 18, alignment: .top)
                        .padding()
                }
                Spacer()
            }
            .padding(5)
            Spacer()
            Text("Daily Log for Today")
                .font(.largeTitle)
                .bold()
                .padding()
            Text(target.activity)
                .font(.title2)
                .fontWeight(.semibold)
                .padding()
            if !isLogged {
                Text("Progress today?")
                    .font(.system(size: 19))
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                VStack {
                    HStack {
                        Button {
                            isProgress = true
                        } label: {
                            Text("Yes")
                                .bold()
                                .font(.title3)
                                .padding()
                                .background(isProgress ? Color("Blue"): .gray.opacity(0.5))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        Button {
                            isProgress = false
                        } label: {
                            Text("No")
                                .bold()
                                .font(.title3)
                                .padding()
                                .background(isProgress ? .gray.opacity(0.5): Color("Blue"))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                }
                if isProgress {
                    Text("Difficulty")
                        .font(.system(size: 19))
                        .foregroundColor(.gray)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    Picker("Difficulty", selection: $difficulty) {
                        Text("Easy").tag(0)
                        Text("Medium").tag(1)
                        Text("Hard").tag(2)
                    }
                    .padding(.horizontal)
                } else {
                    CustomTextField(text: $reason, label: "Why?", isSecure: false)
                        .padding()
                }
                CustomTextField(text: $currentAmountString, label: "Amount Reached", isSecure: false)
                    .padding()
                Picker("Hashtag", selection: $hashtag) {
                    ForEach(0..<hashtags.count, id: \.self) { i in
                        Text("#" + hashtags[i]).tag(i)
                    }
                }
                .padding()
                Button {
                    if !currentAmountString.isEmpty {
                        let currentAmount = Double(currentAmountString)!
                        if target.currentValue <= currentAmount {
                            let index = habitat.account!.targets.firstIndex(of: target)!
                            habitat.account!.targets[index].currentValue = currentAmount
                            habitat.account!.targets[index].lastBestDate = Date().stripTime()
                            Firestore.firestore().collection("Targets").document(target.docId).setData(["currentValue": currentAmount, "lastBestDate": Date().stripTime()], merge: true)
                        }
                        if hashtag == "" {
                            hashtag = hashtags.first!
                        }
                        isLogged = true
                        self.scheduleNotification()
                    } else {
                        alert(title: "Missing fields", message: "Please make sure all fields are filled and answered correctly.", actions: [.init(title: "Ok", style: .default)])
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("Blue"))
                            .frame(height: 48)
                        Text("Done")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding()
            } else {
                if target.currentValue != target.target {
                    Image(uiImage: textToImage(drawText: "#" + hashtag, inImage: textToImage(drawText: "\(floor(target.currentValue) == target.currentValue ? String(Int(target.currentValue)): String(target.currentValue)) / \(floor(target.target) == target.target ? String(Int(target.target)): String(target.target)) \(Units.strings[target.units]!)", inImage: textToImage(drawText: "Day \(Calendar.current.numberOfDaysBetween(target.startDate, and: target.endDate) + 1)", inImage: UIImage(named: "logTemplate")!, atPoint: CGPoint(x: UIImage(named: "logTemplate")!.size.width/2 - 15, y: 122.5), fontSize: 70), atPoint: CGPoint(x: UIImage(named: "logTemplate")!.size.width/2 - 460, y: UIImage(named: "logTemplate")!.size.height/2 - 40), fontSize: 150), atPoint: CGPoint(x: UIImage(named: "logTemplate")!.size.width/2 - 75, y: 1650), fontSize: 70))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Button {
                    let image = textToImage(drawText: "#" + hashtag, inImage: textToImage(drawText: "\(floor(target.currentValue) == target.currentValue ? String(Int(target.currentValue)): String(target.currentValue)) / \(floor(target.target) == target.target ? String(Int(target.target)): String(target.target)) \(Units.strings[target.units]!)", inImage: textToImage(drawText: "Day \(Calendar.current.numberOfDaysBetween(target.startDate, and: target.endDate) + 1)", inImage: UIImage(named: "logTemplate")!, atPoint: CGPoint(x: UIImage(named: "logTemplate")!.size.width/2 - 15, y: 122.5), fontSize: 70), atPoint: CGPoint(x: UIImage(named: "logTemplate")!.size.width/2 - 460, y: UIImage(named: "logTemplate")!.size.height/2 - 40), fontSize: 150), atPoint: CGPoint(x: UIImage(named: "logTemplate")!.size.width/2 - 75, y: 1650), fontSize: 70)
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("Blue"))
                            .frame(height: 48)
                        Text("Save to Camera Roll")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            Spacer()
        }
    }
    private func scheduleNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])  {
            success, error in
            if success {
                print("authorization granted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        let content = UNMutableNotificationContent()
        content.title = "Time to log!"
        content.body = "Open the app and log your progress!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(86400), repeats: false)
        
        let request = UNNotificationRequest(identifier: "logNotif", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
