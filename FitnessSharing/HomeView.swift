//
//  HomeView.swift
//  FitnessSharing
//
//  Created by Krish on 8/20/22.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var habitat: Habitat
    @State private var isCreatingTarget = false
    @State private var isCreatingLog = false
    @State private var targets = [Target]()
    @State private var selectedIndex = Int()
    @State private var logImage = UIImage(named: "logTemplate")!
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(targets, id: \.self) { target in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .frame(maxHeight: UIScreen.main.bounds.height)
                        .padding()
                        .foregroundColor(Color("Blue").opacity(0.3))
                    VStack {
                        ZStack {
                            RingShape(percent: 100, startAngle: -90, drawnClockwise: false)
                                .stroke(style: StrokeStyle(lineWidth: 50, lineCap: .round))
                                .fill(Color("Teal"))
                                .frame(width: 200, height: 200)
                                .opacity(0.4)
                            RingShape(percent: target.currentValue/target.target * 100, startAngle: -90, drawnClockwise: false)
                                .stroke(style: StrokeStyle(lineWidth: 50, lineCap: .round))
                                .fill(Color("Teal"))
                                .frame(width: 200, height: 200)
                        }
                        .padding()
                        Text(target.activity)
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        Text("\(floor(target.currentValue) == target.currentValue ? String(Int(target.currentValue)): String(target.currentValue)) / \(floor(target.target) == target.target ? String(Int(target.target)): String(target.target)) \(Units.strings[target.units]!)")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.horizontal)
                        Text("Best Hit: \(target.lastBestDate.formatted(.dateTime.day().month().year()))")
                            .font(.caption)
                            .padding()
                        Button {
                            isCreatingLog.toggle()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color("Blue"))
                                    .frame(width: 128, height: 48)
                                Text(target.currentValue == target.target ? "Done!":"Log")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        .disabled(target.currentValue == target.target)
                    }
                }
                .tag(targets.firstIndex(of: target))
            }
            .refreshable {
                habitat.account!.reloadData { success in
                    if success {
                        targets = habitat.account!.targets
                    }
                }
            }
            Button {
                isCreatingTarget.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .frame(maxHeight: UIScreen.main.bounds.height)
                        .padding()
                        .foregroundColor(Color("Blue").opacity(0.3))
                    VStack {
                        Image(systemName: "plus.app.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 100)
                        Text("Start a new target")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
            }
            .tag(targets.count)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: habitat.account!.targets.count != 0 ? .automatic : .never))
        .popover(isPresented: $isCreatingTarget) {
            CreateTargetView(showSheet: $isCreatingTarget)
                .environmentObject(habitat)
        }
        .popover(isPresented: $isCreatingLog) {
            CreateLogView(showSheet: $isCreatingLog, logImage: $logImage, target: targets[selectedIndex])
                .environmentObject(habitat)
        }
        .onAppear {
            targets = habitat.account!.targets
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
