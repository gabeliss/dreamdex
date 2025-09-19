import React, { useState } from 'react'
import { Link } from 'react-router-dom'

function Header({ showNavigation = true }) {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)

  return (
    <header className="bg-cloud-white shadow-lg fixed w-full top-0 z-50 border-b border-gray-100">
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-20">
          <Link to="/" className="text-2xl sm:text-3xl font-bold text-primary-purple hover:text-secondary-purple transition-colors duration-300">
            Dreamdex
          </Link>

          {showNavigation ? (
            <>
              {/* Desktop Navigation */}
              <ul className="hidden md:flex items-center space-x-8">
                <li>
                  <a
                    href="#features"
                    className="text-shadow-grey hover:text-primary-purple font-medium transition-colors duration-300 text-lg"
                  >
                    Features
                  </a>
                </li>
                <li>
                  <a
                    href="#support"
                    className="text-shadow-grey hover:text-primary-purple font-medium transition-colors duration-300 text-lg"
                  >
                    Support
                  </a>
                </li>
              </ul>

              {/* Desktop Download Button */}
              <a
                href="https://apps.apple.com/us/app/dreamdex/id6752360041"
                target="_blank"
                rel="noopener noreferrer"
                className="hidden md:block bg-gradient-to-r from-primary-purple to-secondary-purple text-cloud-white px-8 py-3 rounded-2xl font-semibold hover:-translate-y-1 hover:shadow-xl hover:shadow-primary-purple/30 transition-all duration-300 text-lg"
              >
                Download App
              </a>

              {/* Mobile Download Button */}
              <a
                href="https://apps.apple.com/us/app/dreamdex/id6752360041"
                target="_blank"
                rel="noopener noreferrer"
                className="md:hidden bg-gradient-to-r from-primary-purple to-secondary-purple text-cloud-white px-4 py-2 rounded-xl font-semibold hover:-translate-y-1 hover:shadow-lg transition-all duration-300 text-sm"
              >
                Download
              </a>

              {/* Mobile Menu Button */}
              <button
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                className="md:hidden p-2 rounded-lg text-shadow-grey hover:text-primary-purple hover:bg-gray-100 transition-all duration-300"
                aria-label="Toggle mobile menu"
              >
                <svg
                  className="w-6 h-6"
                  fill="none"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  {isMobileMenuOpen ? (
                    <path d="M6 18L18 6M6 6l12 12" />
                  ) : (
                    <path d="M4 6h16M4 12h16M4 18h16" />
                  )}
                </svg>
              </button>
            </>
          ) : (
            <Link
              to="/"
              className="bg-gradient-to-r from-primary-purple to-secondary-purple text-cloud-white px-4 sm:px-6 py-2 sm:py-3 rounded-2xl font-semibold flex items-center gap-2 sm:gap-3 hover:-translate-y-1 transition-all duration-300 text-sm sm:text-base"
            >
              <i className="fas fa-arrow-left"></i>
              <span className="hidden sm:inline">Back to Home</span>
              <span className="sm:hidden">Back</span>
            </Link>
          )}
        </div>

        {/* Mobile Navigation Menu */}
        {showNavigation && isMobileMenuOpen && (
          <div className="md:hidden border-t border-gray-100 bg-cloud-white">
            <div className="px-4 py-4 space-y-4">
              <a
                href="#features"
                onClick={() => setIsMobileMenuOpen(false)}
                className="block text-shadow-grey hover:text-primary-purple font-medium transition-colors duration-300 text-lg py-2"
              >
                Features
              </a>
              <a
                href="#support"
                onClick={() => setIsMobileMenuOpen(false)}
                className="block text-shadow-grey hover:text-primary-purple font-medium transition-colors duration-300 text-lg py-2"
              >
                Support
              </a>
            </div>
          </div>
        )}
      </nav>
    </header>
  )
}

export default Header