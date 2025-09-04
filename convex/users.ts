import { v } from "convex/values";
import { mutation, query } from "./_generated/server";

// Query to get user by Clerk ID
export const getByClerkId = query({
  args: { clerkId: v.string() },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", args.clerkId))
      .first();
    
    return user;
  },
});

// Mutation to create or update user
export const upsert = mutation({
  args: {
    clerkId: v.string(),
    email: v.string(),
    firstName: v.optional(v.string()),
    lastName: v.optional(v.string()),
    profileImageUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const existingUser = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", args.clerkId))
      .first();

    if (existingUser) {
      // Update existing user
      await ctx.db.patch(existingUser._id, {
        email: args.email,
        firstName: args.firstName,
        lastName: args.lastName,
        profileImageUrl: args.profileImageUrl,
        lastLoginAt: Date.now(),
      });
      
      return existingUser._id;
    } else {
      // Create new user
      const userId = await ctx.db.insert("users", {
        clerkId: args.clerkId,
        email: args.email,
        firstName: args.firstName,
        lastName: args.lastName,
        profileImageUrl: args.profileImageUrl,
        totalDreams: 0,
        lastLoginAt: Date.now(),
        preferences: {
          enableNotifications: true,
          dreamReminders: true,
          aiAnalysis: true,
          imageGeneration: true,
        },
      });
      
      return userId;
    }
  },
});

// Mutation to update user preferences
export const updatePreferences = mutation({
  args: {
    clerkId: v.string(),
    preferences: v.object({
      enableNotifications: v.boolean(),
      dreamReminders: v.boolean(),
      aiAnalysis: v.boolean(),
      imageGeneration: v.boolean(),
    }),
  },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", args.clerkId))
      .first();

    if (!user) {
      throw new Error("User not found");
    }

    await ctx.db.patch(user._id, {
      preferences: args.preferences,
    });

    return user._id;
  },
});

// Mutation to update user profile
export const updateProfile = mutation({
  args: {
    clerkId: v.string(),
    firstName: v.optional(v.string()),
    lastName: v.optional(v.string()),
    profileImageUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", args.clerkId))
      .first();

    if (!user) {
      throw new Error("User not found");
    }

    await ctx.db.patch(user._id, {
      firstName: args.firstName,
      lastName: args.lastName,
      profileImageUrl: args.profileImageUrl,
    });

    return user._id;
  },
});

// Query to get user stats
export const getStats = query({
  args: { clerkId: v.string() },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", args.clerkId))
      .first();

    if (!user) {
      return null;
    }

    // Get dream stats
    const dreams = await ctx.db
      .query("dreams")
      .withIndex("by_user", (q) => q.eq("userId", args.clerkId))
      .collect();

    const now = Date.now();
    const weekAgo = now - 7 * 24 * 60 * 60 * 1000;
    const monthAgo = now - 30 * 24 * 60 * 60 * 1000;
    
    const thisWeek = dreams.filter(dream => dream._creationTime > weekAgo);
    const thisMonth = dreams.filter(dream => dream._creationTime > monthAgo);
    const favorites = dreams.filter(dream => dream.isFavorite);
    const withImages = dreams.filter(dream => dream.aiGeneratedImageUrl);
    const withAnalysis = dreams.filter(dream => dream.analysis);

    return {
      user: {
        id: user._id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        profileImageUrl: user.profileImageUrl,
        totalDreams: user.totalDreams,
        lastLoginAt: user.lastLoginAt,
        preferences: user.preferences,
      },
      dreamStats: {
        total: dreams.length,
        thisWeek: thisWeek.length,
        thisMonth: thisMonth.length,
        favorites: favorites.length,
        withImages: withImages.length,
        withAnalysis: withAnalysis.length,
        averagePerWeek: dreams.length > 0 ? Math.round(dreams.length / Math.max(1, Math.floor((now - dreams[dreams.length - 1]._creationTime) / (7 * 24 * 60 * 60 * 1000)))) : 0,
      },
    };
  },
});