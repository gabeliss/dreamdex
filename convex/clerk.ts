import { v } from "convex/values";
import { action } from "./_generated/server";

// Action to delete user from Clerk using backend API
export const deleteUser = action({
  args: { 
    clerkUserId: v.string(),
    clerkSecretKey: v.string()
  },
  handler: async (ctx, args) => {
    const clerkSecretKey = args.clerkSecretKey;
    
    if (!clerkSecretKey) {
      throw new Error("CLERK_SECRET_KEY not found in environment variables");
    }

    try {
      // Call Clerk's backend API to delete the user
      const response = await fetch(`https://api.clerk.dev/v1/users/${args.clerkUserId}`, {
        method: "DELETE",
        headers: {
          "Authorization": `Bearer ${clerkSecretKey}`,
          "Content-Type": "application/json",
        },
      });

      if (!response.ok) {
        const errorData = await response.text();
        console.error(`Clerk API error: ${response.status} - ${errorData}`);
        throw new Error(`Failed to delete user from Clerk: ${response.status}`);
      }

      console.log(`Successfully deleted Clerk user: ${args.clerkUserId}`);
      
      return {
        success: true,
        message: "User successfully deleted from Clerk",
      };
    } catch (error: any) {
      console.error("Error deleting user from Clerk:", error);
      throw new Error(`Failed to delete user from Clerk: ${error?.message || error}`);
    }
  },
});