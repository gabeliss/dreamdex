import React from 'react'
import { Link } from 'react-router-dom'

function Footer() {
  return (
    <footer className="bg-night-grey text-cloud-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-12">
          {/* Brand Section */}
          <div className="lg:col-span-2">
            <h3 className="text-2xl font-bold text-cloud-white mb-6">Dreamdex</h3>
            <p className="text-lg text-mist-grey leading-relaxed max-w-2xl">
              Your AI-powered companion for dream exploration and understanding.
              Discover the hidden meanings in your nightly adventures and unlock
              the secrets of your subconscious mind.
            </p>
          </div>

          {/* Legal Links */}
          <div>
            <h3 className="text-lg font-semibold text-cloud-white mb-6">Legal</h3>
            <ul className="space-y-4">
              <li>
                <Link
                  to="/privacy"
                  className="text-mist-grey hover:text-light-purple transition-colors duration-300 text-lg"
                >
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link
                  to="/terms"
                  className="text-mist-grey hover:text-light-purple transition-colors duration-300 text-lg"
                >
                  Terms of Service
                </Link>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Section */}
        <div className="border-t border-shadow-grey pt-8 mt-12 text-center">
          <p className="text-mist-grey text-lg">
            &copy; 2025 Dreamdex. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  )
}

export default Footer