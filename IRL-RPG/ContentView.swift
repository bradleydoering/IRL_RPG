//
//  ContentView.swift
//  IRL-RPG
//
//  Created by Brad Doering on 1/3/26.
//

import SwiftUI
import CoreData
import UIKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "kindRaw", ascending: true)],
        animation: .default)
    private var skills: FetchedResults<Skill>
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)

    var body: some View {
        NavigationView {
            ScrollView {
                if orderedSkills.isEmpty {
                    VStack(spacing: 12) {
                        Text("Loading skills...")
                            .font(AppFont.custom(16, weight: .semibold))
                            .foregroundColor(.secondary)
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(orderedSkills) { skill in
                            NavigationLink {
                                SkillDetailView(skill: skill)
                            } label: {
                                SkillCard(skill: skill)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                PersistenceController.shared.seedSkillsIfNeeded(context: viewContext)
            }
        }
    }

    private var orderedSkills: [Skill] {
        let map: [String: Skill] = Dictionary(uniqueKeysWithValues: skills.compactMap { skill in
            guard let raw = skill.kindRaw else { return nil }
            return (raw, skill)
        })
        return SkillKind.allCases.compactMap { map[$0.rawValue] }
    }
}

private struct SkillCard: View {
    let skill: Skill

    var body: some View {
        GeometryReader { proxy in
            let leftWidth = proxy.size.width * 0.5
            let rightWidth = proxy.size.width * 0.5

            HStack(spacing: 0) {
                if let uiImage = UIImage(named: skill.assetName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: leftWidth, height: proxy.size.height, alignment: .leading)
                        .clipped()
                } else {
                    Image(systemName: skill.iconName)
                        .font(.system(size: min(leftWidth, proxy.size.height) * 0.6))
                        .foregroundColor(Color(red: 0.85, green: 0.83, blue: 0.78))
                        .frame(width: leftWidth, height: proxy.size.height, alignment: .leading)
                        .clipped()
                }

                HStack(spacing: 3) {
                    Text("\(skill.levelValue)")
                        .foregroundColor(Color(red: 0.98, green: 0.90, blue: 0.35))
                    Text("/")
                        .foregroundColor(.black)
                    Text("99")
                        .foregroundColor(Color(red: 0.98, green: 0.90, blue: 0.35))
                }
                .font(AppFont.custom(20, weight: .semibold))
                .frame(width: rightWidth, height: proxy.size.height, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 84)
        .background(
            CutCornerRectangle(cornerSize: 6)
                .fill(Color(red: 0.35, green: 0.33, blue: 0.30))
        )
        .overlay(
            CutCornerRectangle(cornerSize: 6)
                .stroke(Color(red: 0.20, green: 0.19, blue: 0.17), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
    }
}

private struct CutCornerRectangle: Shape {
    let cornerSize: CGFloat

    func path(in rect: CGRect) -> Path {
        let c = min(cornerSize, min(rect.width, rect.height) / 2)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + c, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - c, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + c))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - c))
        path.addLine(to: CGPoint(x: rect.maxX - c, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + c, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - c))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + c))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
