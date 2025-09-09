import { v } from "convex/values";
import { mutation, query, action } from "./_generated/server";
import { api } from "./_generated/api";

// Query to get user by Auth ID (Firebase UID)
export const getByAuthId = query({
  args: { authId: v.string() },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_auth_id", (q) => q.eq("authId", args.authId))
      .first();
    
    return user;
  },
});


// Mutation to create or update user
export const upsert = mutation({
  args: {
    authId: v.string(), // Firebase UID
    email: v.string(),
    firstName: v.optional(v.string()),
    lastName: v.optional(v.string()),
    profileImageUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const existingUser = await ctx.db
      .query("users")
      .withIndex("by_auth_id", (q) => q.eq("authId", args.authId))
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
        authId: args.authId, // Store Firebase UID
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
    authId: v.string(),
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
      .withIndex("by_auth_id", (q) => q.eq("authId", args.authId))
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
    authId: v.string(),
    firstName: v.optional(v.string()),
    lastName: v.optional(v.string()),
    profileImageUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_auth_id", (q) => q.eq("authId", args.authId))
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
  args: { authId: v.string() },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_auth_id", (q) => q.eq("authId", args.authId))
      .first();

    if (!user) {
      return null;
    }

    // Get dream stats
    const dreams = await ctx.db
      .query("dreams")
      .withIndex("by_user", (q) => q.eq("userId", args.authId))
      .collect();

    const now = Date.now();
    const weekAgo = now - 7 * 24 * 60 * 60 * 1000;
    const monthAgo = now - 30 * 24 * 60 * 60 * 1000;
    
    const thisWeek = dreams.filter(dream => dream._creationTime > weekAgo);
    const thisMonth = dreams.filter(dream => dream._creationTime > monthAgo);
    const favorites = dreams.filter(dream => dream.isFavorite);
    const withImages = dreams.filter(dream => dream.aiGeneratedImageStorageId);
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

// Action to delete user account and all associated data (Firebase Auth handles user deletion)
export const deleteAccount = action({
  args: { 
    authId: v.string(),
    firebaseIdToken: v.optional(v.string()) // For future Firebase integration
  },
  handler: async (ctx, args): Promise<{success: boolean, deletedDreams: number, message: string}> => {
    // First, delete from Convex database
    const user = await ctx.runQuery(api.users.getByAuthId, { authId: args.authId });
    
    if (!user) {
      throw new Error("User not found");
    }

    // Delete all dreams associated with this user
    const dreams: any[] = await ctx.runQuery(api.dreams.list, { userId: args.authId });
    
    // Delete each dream individually
    for (const dream of dreams) {
      await ctx.runMutation(api.dreams.remove, { id: dream._id, userId: args.authId });
    }

    // Delete the user record from Convex
    await ctx.runMutation(api.users.remove, { authId: args.authId });

    // Note: Firebase user deletion is handled client-side or via Admin SDK
    // The client should delete the Firebase user after this action succeeds

    return {
      success: true,
      deletedDreams: dreams.length,
      message: `Account deleted successfully. Removed ${dreams.length} dreams.`
    };
  },
});

// Helper mutation to remove user (called by deleteAccount action)
export const remove = mutation({
  args: { authId: v.string() },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_auth_id", (q) => q.eq("authId", args.authId))
      .first();

    if (user) {
      await ctx.db.delete(user._id);
    }
    
    return user?._id;
  },
});