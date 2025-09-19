import React from 'react'
import { Link } from 'react-router-dom'

function Header({ showNavigation = true }) {

  return (
    <header className="bg-cloud-white shadow-lg fixed w-full top-0 z-50 border-b border-gray-100">
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-20">
          <Link to="/" className="text-2xl sm:text-3xl font-bold text-primary-purple hover:text-secondary-purple transition-colors duration-300">
            Dreamdex
          </Link>

          {showNavigation ? (
            <>
              {/* Desktop Download Button */}
              <a
                href="https://apps.apple.com/us/app/dreamdex/id6752360041"
                target="_blank"
                rel="noopener noreferrer"
                className="hidden md:flex items-center gap-3 bg-gradient-to-r from-primary-purple to-secondary-purple text-cloud-white px-6 py-3 rounded-2xl font-semibold hover:-translate-y-1 hover:shadow-xl hover:shadow-primary-purple/30 transition-all duration-300 text-lg"
              >
                <i className="fab fa-apple text-xl"></i>
                Download for iOS
              </a>

              {/* Mobile Download Button */}
              <a
                href="https://apps.apple.com/us/app/dreamdex/id6752360041"
                target="_blank"
                rel="noopener noreferrer"
                className="md:hidden flex items-center gap-2 bg-gradient-to-r from-primary-purple to-secondary-purple text-cloud-white px-4 py-2 rounded-xl font-semibold hover:-translate-y-1 hover:shadow-lg transition-all duration-300 text-sm"
              >
                <i className="fab fa-apple text-lg"></i>
                Download
              </a>
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

      </nav>
    </header>
  )
}

export default Header