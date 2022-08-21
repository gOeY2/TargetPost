//
//  CreateTargetView.swift
//  FitnessSharing
//
//  Created by Krish on 8/20/22.
//

import SwiftUI
import FirebaseFirestore

struct CreateTargetView: View {
    
    @Binding var showSheet: Bool
    @EnvironmentObject var habitat: Habitat
    @State private var activityName = String()
    @State private var currentValueString = String()
    @State private var targetString = String()
    @State private var unitIndex = Int()
    @State private var targetDate = Date()
    
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
            Text("Start a new target")
                .font(.largeTitle)
                .bold()
            CustomTextField(text: $activityName, label: "Activity", isSecure: false)
                .padding()
            CustomTextField(text: $currentValueString, label: "Current Amount", isSecure: false)
                .padding()
            CustomTextField(text: $targetString, label: "Target", isSecure: false)
                .padding()
            HStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Units")
                            .font(.system(size: 19))
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                        Picker("Units", selection: $unitIndex) {
                            ForEach(0..<Units.allCases.count, id: \.self) { i in
                                Text(Units.strings[Units.allCases[i]]!).tag(i)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Target End Date")
                            .font(.system(size: 19))
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                        DatePicker("", selection: $targetDate, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                    }
                    Spacer()
                }
                .padding()
            }
            
            Button {
                if !activityName.isEmpty, !currentValueString.isEmpty, !targetString.isEmpty, targetDate != Date().stripTime() {
                    let currentValue = Double(currentValueString) ?? 0
                    let targetValue = Double(targetString) ?? 0
                    let docId = FirebaseFunctions.shared.createDocId()
                    Firestore.firestore().collection("Targets").document(docId).setData(["activity": activityName, "currentValue": currentValue, "target": targetValue, "startDate": Date().stripTime(), "endDate": targetDate, "unitIndex": unitIndex]) { err in
                        if let error = err {
                            print(error.localizedDescription)
                        } else {
                            let target = Target(activity: activityName, currentValue: currentValue, target: targetValue, units: Units.allCases[unitIndex], startDate: Date().stripTime(), endDate: targetDate.stripTime(), lastBestDate: Date().stripTime(), docId: docId)
                            habitat.account!.targets.append(target)
                            var targetStrings = [String]()
                            for classTarget in habitat.account!.targets {
                                targetStrings.append(classTarget.docId)
                            }
                            Firestore.firestore().collection("Accounts").document(habitat.account!.uid).setData(["targets": targetStrings], merge: true)
                            self.showSheet.toggle()
                        }
                    }
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
            Spacer()
        }
    }
}
