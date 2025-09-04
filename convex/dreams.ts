import { v } from "convex/values";
import { mutation, query } from "./_generated/server";

// Query to list all dreams for a user
export const list = query({
  args: { userId: v.string() },
  handler: async (ctx, args) => {
    const dreams = await ctx.db
      .query("dreams")
      .withIndex("by_user", (q) => q.eq("userId", args.userId))
      .order("desc")
      .collect();
    
    return dreams;
  },
});

// Query to get a specific dream
export const get = query({
  args: { id: v.id("dreams"), userId: v.string() },
  handler: async (ctx, args) => {
    const dream = await ctx.db.get(args.id);
    
    if (!dream || dream.userId !== args.userId) {
      return null;
    }
    
    return dream;
  },
});

// Mutation to create a new dream
export const create = mutation({
  args: {
    userId: v.string(),
    title: v.string(),
    content: v.string(),
    rawTranscript: v.string(),
    type: v.string(),
    aiGeneratedImageUrl: v.optional(v.string()),
    aiImagePrompt: v.optional(v.string()),
    isGeneratingImage: v.optional(v.boolean()),
    tags: v.array(v.string()),
    isFavorite: v.boolean(),
    analysis: v.optional(v.object({
      themes: v.array(v.string()),
      characters: v.array(v.string()),
      locations: v.array(v.string()),
      emotions: v.array(v.string()),
      summary: v.string(),
      lucidityScore: v.number(),
      emotionalIntensity: v.number(),
    })),
  },
  handler: async (ctx, args) => {
    const dreamId = await ctx.db.insert("dreams", {
      userId: args.userId,
      title: args.title,
      content: args.content,
      rawTranscript: args.rawTranscript,
      type: args.type,
      aiGeneratedImageUrl: args.aiGeneratedImageUrl,
      aiImagePrompt: args.aiImagePrompt,
      isGeneratingImage: args.isGeneratingImage ?? false,
      tags: args.tags,
      isFavorite: args.isFavorite,
      analysis: args.analysis,
    });
    
    // Update user's total dreams count
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", args.userId))
      .first();
    
    if (user) {
      await ctx.db.patch(user._id, {
        totalDreams: user.totalDreams + 1,
      });
    }
    
    return dreamId;
  },
});

// Mutation to update a dream
export const update = mutation({
  args: {
    id: v.id("dreams"),
    userId: v.string(),
    updates: v.object({
      title: v.optional(v.string()),
      content: v.optional(v.string()),
      type: v.optional(v.string()),
      aiGeneratedImageUrl: v.optional(v.string()),
      aiImagePrompt: v.optional(v.string()),
      isGeneratingImage: v.optional(v.boolean()),
      tags: v.optional(v.array(v.string())),
      isFavorite: v.optional(v.boolean()),
      analysis: v.optional(v.object({
        themes: v.array(v.string()),
        characters: v.array(v.string()),
        locations: v.array(v.string()),
        emotions: v.array(v.string()),
        summary: v.string(),
        lucidityScore: v.number(),
        emotionalIntensity: v.number(),
      })),
    }),
  },
  handler: async (ctx, args) => {
    const dream = await ctx.db.get(args.id);
    
    if (!dream || dream.userId !== args.userId) {
      throw new Error("Dream not found or access denied");
    }
    
    await ctx.db.patch(args.id, args.updates);
    
    return args.id;
  },
});

// Mutation to delete a dream
export const remove = mutation({
  args: { id: v.id("dreams"), userId: v.string() },
  handler: async (ctx, args) => {
    const dream = await ctx.db.get(args.id);
    
    if (!dream || dream.userId !== args.userId) {
      throw new Error("Dream not found or access denied");
    }
    
    await ctx.db.delete(args.id);
    
    // Update user's total dreams count
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", args.userId))
      .first();
    
    if (user && user.totalDreams > 0) {
      await ctx.db.patch(user._id, {
        totalDreams: user.totalDreams - 1,
      });
    }
    
    return args.id;
  },
});

// Query to search dreams
export const search = query({
  args: { userId: v.string(), query: v.string() },
  handler: async (ctx, args) => {
    const results = await ctx.db
      .query("dreams")
      .withSearchIndex("search_content", (q) =>
        q.search("content", args.query).eq("userId", args.userId)
      )
      .collect();
    
    // Also search in titles
    const titleResults = await ctx.db
      .query("dreams")
      .withSearchIndex("search_title", (q) =>
        q.search("title", args.query).eq("userId", args.userId)
      )
      .collect();
    
    // Combine and deduplicate results
    const allResults = [...results, ...titleResults];
    const uniqueResults = allResults.filter(
      (dream, index, self) =>
        index === self.findIndex((d) => d._id === dream._id)
    );
    
    return uniqueResults.sort((a, b) => b._creationTime - a._creationTime);
  },
});

// Query to get dream statistics
export const stats = query({
  args: { userId: v.string() },
  handler: async (ctx, args) => {
    const allDreams = await ctx.db
      .query("dreams")
      .withIndex("by_user", (q) => q.eq("userId", args.userId))
      .collect();
    
    const now = Date.now();
    const weekAgo = now - 7 * 24 * 60 * 60 * 1000;
    const monthAgo = now - 30 * 24 * 60 * 60 * 1000;
    
    const thisWeek = allDreams.filter(dream => dream._creationTime > weekAgo);
    const thisMonth = allDreams.filter(dream => dream._creationTime > monthAgo);
    const favorites = allDreams.filter(dream => dream.isFavorite);
    
    return {
      total: allDreams.length,
      thisWeek: thisWeek.length,
      thisMonth: thisMonth.length,
      favorites: favorites.length,
    };
  },
});

// Query to get dreams by type
export const getByType = query({
  args: { userId: v.string(), type: v.string() },
  handler: async (ctx, args) => {
    const dreams = await ctx.db
      .query("dreams")
      .withIndex("by_user", (q) => q.eq("userId", args.userId))
      .filter((q) => q.eq(q.field("type"), args.type))
      .order("desc")
      .collect();
    
    return dreams;
  },
});

// Query to get favorite dreams
export const getFavorites = query({
  args: { userId: v.string() },
  handler: async (ctx, args) => {
    const dreams = await ctx.db
      .query("dreams")
      .withIndex("by_user_favorite", (q) =>
        q.eq("userId", args.userId).eq("isFavorite", true)
      )
      .order("desc")
      .collect();
    
    return dreams;
  },
});