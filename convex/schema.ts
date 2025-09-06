import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  dreams: defineTable({
    userId: v.string(),
    title: v.string(),
    content: v.string(),
    rawTranscript: v.string(),
    type: v.string(), // DreamType enum as string
    aiGeneratedImageStorageId: v.optional(v.id("_storage")),
    aiImagePrompt: v.optional(v.string()),
    isGeneratingImage: v.optional(v.boolean()),
    tags: v.array(v.string()),
    isFavorite: v.boolean(),
    
    // AI Analysis
    analysis: v.optional(v.object({
      themes: v.array(v.string()),
      characters: v.array(v.string()),
      locations: v.array(v.string()),
      emotions: v.array(v.string()),
      summary: v.string(),
      lucidityScore: v.number(),
      emotionalIntensity: v.number(),
    })),
  })
    .index("by_user", ["userId"])
    .index("by_user_favorite", ["userId", "isFavorite"])
    .searchIndex("search_content", {
      searchField: "content",
      filterFields: ["userId"],
    })
    .searchIndex("search_title", {
      searchField: "title", 
      filterFields: ["userId"],
    }),

  users: defineTable({
    clerkId: v.string(),
    email: v.string(),
    firstName: v.optional(v.string()),
    lastName: v.optional(v.string()),
    profileImageUrl: v.optional(v.string()),
    
    // User preferences
    preferences: v.optional(v.object({
      enableNotifications: v.boolean(),
      dreamReminders: v.boolean(),
      aiAnalysis: v.boolean(),
      imageGeneration: v.boolean(),
    })),
    
    // Stats
    totalDreams: v.number(),
    lastLoginAt: v.optional(v.number()),
  })
    .index("by_clerk_id", ["clerkId"])
    .index("by_email", ["email"]),
});