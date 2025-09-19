/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'primary-purple': '#6B46C1',
        'secondary-purple': '#9333EA',
        'light-purple': '#DDD6FE',
        'ultra-light-purple': '#F3F0FF',
        'dream-blue': '#4F46E5',
        'light-blue': '#E0E7FF',
        'star-yellow': '#FBBF24',
        'cloud-white': '#FEFEFE',
        'fog-grey': '#F9FAFB',
        'mist-grey': '#E5E7EB',
        'shadow-grey': '#6B7280',
        'night-grey': '#374151',
        'dream-pink': '#EC4899',
        'light-pink': '#FCE7F3',
        'error-red': '#EF4444',
      },
      fontFamily: {
        'poppins': ['Poppins', 'sans-serif'],
      },
    },
  },
  plugins: [],
}