import React from 'react'
import Header from '../components/Header'
import Footer from '../components/Footer'

function Home() {
  return (
    <div className="min-h-screen bg-white">
      <Header />

      {/* Hero Section */}
      <section className="relative pt-32 pb-24 bg-gradient-to-br from-ultra-light-purple via-light-blue to-ultra-light-purple overflow-hidden">
        {/* Background decoration */}
        <div className="absolute inset-0 bg-gradient-to-r from-primary-purple/5 via-transparent to-secondary-purple/5"></div>

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            {/* Main headline */}
            <h1 className="text-6xl sm:text-7xl lg:text-8xl font-bold leading-tight mb-8">
              <span className="text-night-grey">Your AI-Powered</span>
              <br />
              <span className="bg-gradient-to-r from-primary-purple to-secondary-purple bg-clip-text text-transparent">
                Dream Journal
              </span>
            </h1>

            {/* Subtitle */}
            <p className="text-xl sm:text-2xl text-shadow-grey mb-16 max-w-4xl mx-auto leading-relaxed">
              Capture, analyze, and understand your dreams with the help of advanced AI.
              <br className="hidden sm:block" />
              Discover patterns, meanings, and insights in your nightly adventures.
            </p>

            {/* Feature pills with glassmorphism */}
            <div className="flex flex-wrap justify-center gap-4 lg:gap-6 mb-20">
              <div className="group bg-white/70 backdrop-blur-xl border border-white/20 px-6 py-4 rounded-full shadow-xl hover:shadow-2xl hover:scale-105 transition-all duration-300">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-dream-blue to-primary-purple rounded-full flex items-center justify-center shadow-lg">
                    <i className="fas fa-brain text-white text-lg"></i>
                  </div>
                  <span className="font-bold text-night-grey text-lg">AI Analysis</span>
                </div>
              </div>

              <div className="group bg-white/70 backdrop-blur-xl border border-white/20 px-6 py-4 rounded-full shadow-xl hover:shadow-2xl hover:scale-105 transition-all duration-300">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-secondary-purple to-dream-pink rounded-full flex items-center justify-center shadow-lg">
                    <i className="fas fa-microphone text-white text-lg"></i>
                  </div>
                  <span className="font-bold text-night-grey text-lg">Voice Recording</span>
                </div>
              </div>

              <div className="group bg-white/70 backdrop-blur-xl border border-white/20 px-6 py-4 rounded-full shadow-xl hover:shadow-2xl hover:scale-105 transition-all duration-300">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-dream-pink to-star-yellow rounded-full flex items-center justify-center shadow-lg">
                    <i className="fas fa-chart-line text-white text-lg"></i>
                  </div>
                  <span className="font-bold text-night-grey text-lg">Dream Insights</span>
                </div>
              </div>

              <div className="group bg-white/70 backdrop-blur-xl border border-white/20 px-6 py-4 rounded-full shadow-xl hover:shadow-2xl hover:scale-105 transition-all duration-300">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-primary-purple to-secondary-purple rounded-full flex items-center justify-center shadow-lg">
                    <i className="fas fa-shield-alt text-white text-lg"></i>
                  </div>
                  <span className="font-bold text-night-grey text-lg">Private & Secure</span>
                </div>
              </div>
            </div>

            {/* App Screenshots */}
            <div className="relative">
              <div className="grid grid-cols-2 lg:grid-cols-4 gap-6 lg:gap-8 max-w-5xl mx-auto">
                <div className="flex justify-center">
                  <img
                    src="/assets/image1.jpeg"
                    alt="Dreamdex App Screenshot 1"
                    className="w-48 h-auto max-h-96 object-cover rounded-3xl shadow-2xl hover:scale-105 hover:-translate-y-2 transition-all duration-300 border-2 border-white/50"
                  />
                </div>
                <div className="flex justify-center">
                  <img
                    src="/assets/image2.jpeg"
                    alt="Dreamdex App Screenshot 2"
                    className="w-48 h-auto max-h-96 object-cover rounded-3xl shadow-2xl hover:scale-105 hover:-translate-y-2 transition-all duration-300 border-2 border-white/50"
                  />
                </div>
                <div className="flex justify-center">
                  <img
                    src="/assets/image3.jpeg"
                    alt="Dreamdex App Screenshot 3"
                    className="w-48 h-auto max-h-96 object-cover rounded-3xl shadow-2xl hover:scale-105 hover:-translate-y-2 transition-all duration-300 border-2 border-white/50"
                  />
                </div>
                <div className="flex justify-center">
                  <img
                    src="/assets/image4.jpeg"
                    alt="Dreamdex App Screenshot 4"
                    className="w-48 h-auto max-h-96 object-cover rounded-3xl shadow-2xl hover:scale-105 hover:-translate-y-2 transition-all duration-300 border-2 border-white/50"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-32 bg-white relative overflow-hidden" id="features">
        {/* Background decoration */}
        <div className="absolute top-0 left-0 w-full h-full bg-gradient-to-b from-ultra-light-purple/20 to-transparent"></div>

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-24">
            <h2 className="text-5xl sm:text-6xl font-bold mb-8">
              <span className="text-night-grey">Powerful Features for</span>
              <br />
              <span className="bg-gradient-to-r from-primary-purple to-secondary-purple bg-clip-text text-transparent">
                Dream Exploration
              </span>
            </h2>
            <p className="text-xl text-shadow-grey max-w-3xl mx-auto leading-relaxed">
              Everything you need to capture, analyze, and understand your dreams in one beautiful app.
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
            {/* AI Dream Analysis */}
            <div className="group relative">
              <div className="absolute inset-0 bg-gradient-to-br from-dream-blue/20 to-dream-pink/20 rounded-3xl blur-xl group-hover:blur-2xl transition-all duration-500"></div>
              <div className="relative bg-white/80 backdrop-blur-xl border border-white/20 p-12 rounded-3xl shadow-2xl hover:shadow-3xl transition-all duration-500 hover:-translate-y-2">
                <div className="text-center">
                  <div className="w-24 h-24 mx-auto mb-8 rounded-3xl bg-gradient-to-br from-dream-blue to-dream-pink flex items-center justify-center shadow-2xl group-hover:scale-110 transition-transform duration-300">
                    <i className="fas fa-brain text-white text-4xl"></i>
                  </div>
                  <h3 className="text-3xl font-bold text-night-grey mb-6">AI Dream Analysis</h3>
                  <p className="text-lg text-shadow-grey leading-relaxed">
                    Get deep insights into your dreams with advanced AI that understands symbolism, emotions, and patterns in your subconscious experiences.
                  </p>
                </div>
              </div>
            </div>

            {/* Voice Recording */}
            <div className="group relative">
              <div className="absolute inset-0 bg-gradient-to-br from-primary-purple/20 to-secondary-purple/20 rounded-3xl blur-xl group-hover:blur-2xl transition-all duration-500"></div>
              <div className="relative bg-white/80 backdrop-blur-xl border border-white/20 p-12 rounded-3xl shadow-2xl hover:shadow-3xl transition-all duration-500 hover:-translate-y-2">
                <div className="text-center">
                  <div className="w-24 h-24 mx-auto mb-8 rounded-3xl bg-gradient-to-br from-primary-purple to-secondary-purple flex items-center justify-center shadow-2xl group-hover:scale-110 transition-transform duration-300">
                    <i className="fas fa-microphone text-white text-4xl"></i>
                  </div>
                  <h3 className="text-3xl font-bold text-night-grey mb-6">Voice Recording</h3>
                  <p className="text-lg text-shadow-grey leading-relaxed">
                    Capture your dreams instantly upon waking with voice recording. No need to fumble with typing in the dark.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="relative py-32 bg-gradient-to-br from-primary-purple via-secondary-purple to-dream-pink overflow-hidden" id="download">
        {/* Background effects */}
        <div className="absolute inset-0 bg-gradient-to-r from-black/20 via-transparent to-black/20"></div>
        <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(ellipse_at_center,_transparent_0%,_rgba(0,0,0,0.1)_100%)]"></div>

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-5xl sm:text-6xl font-bold text-white mb-8">
            Start Your Dream Journey Today
          </h2>
          <p className="text-2xl text-white/90 mb-16 max-w-3xl mx-auto leading-relaxed">
            Join thousands of dreamers who are already exploring their subconscious with Dreamdx
          </p>

          <div className="flex justify-center">
            <a
              href="https://apps.apple.com/us/app/dreamdex/id6752360041"
              target="_blank"
              rel="noopener noreferrer"
              className="group relative bg-white/95 backdrop-blur-xl text-primary-purple px-12 py-6 rounded-2xl font-bold text-xl flex items-center justify-center gap-6 hover:bg-white hover:scale-105 transition-all duration-300 shadow-2xl hover:shadow-3xl border border-white/20 min-w-[300px]"
            >
              <div className="w-12 h-12 bg-gradient-to-br from-primary-purple to-secondary-purple rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                <i className="fab fa-apple text-white text-2xl"></i>
              </div>
              <div className="text-left">
                <div className="text-sm opacity-70 font-medium">Download for</div>
                <div className="text-2xl font-bold">iOS</div>
              </div>
            </a>
          </div>
        </div>
      </section>

      {/* Support Section */}
      <section className="py-32 bg-fog-grey relative overflow-hidden" id="support">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-5xl font-bold text-night-grey mb-8">Need Help?</h2>
          <p className="text-xl text-shadow-grey mb-16 max-w-2xl mx-auto leading-relaxed">
            We're here to help! Contact us for support, questions, or feedback.
          </p>

          <div className="max-w-lg mx-auto">
            <div className="relative group">
              <div className="absolute inset-0 bg-gradient-to-br from-primary-purple/20 to-secondary-purple/20 rounded-3xl blur-xl group-hover:blur-2xl transition-all duration-500"></div>
              <div className="relative bg-white/90 backdrop-blur-xl border border-white/20 rounded-3xl p-6 sm:p-12 shadow-2xl hover:shadow-3xl transition-all duration-500 hover:-translate-y-2">
                <div className="w-20 h-20 mx-auto mb-8 bg-gradient-to-br from-primary-purple to-secondary-purple rounded-2xl flex items-center justify-center shadow-xl group-hover:scale-110 transition-transform duration-300">
                  <i className="fas fa-envelope text-white text-3xl"></i>
                </div>
                <h3 className="text-3xl font-bold text-primary-purple mb-6">Contact Support</h3>
                <div className="bg-fog-grey/80 rounded-2xl p-4 sm:p-8 mb-6 border border-gray-200/50">
                  <p className="text-lg sm:text-2xl font-bold text-night-grey font-mono break-all">
                    contact@dreamdxapp.com
                  </p>
                </div>
                <p className="text-shadow-grey text-lg">
                  We typically respond within 24 hours.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  )
}

export default Home