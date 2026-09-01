import React, { useState } from 'react';
import { Shield, Sparkles, Smartphone, Bell, Receipt, CheckCircle, ArrowRight } from 'lucide-react';
import { Language, TRANSLATIONS } from '../utils/translations';

interface OnboardingFlowProps {
  onComplete: () => void;
  onLoginClick: () => void;
  language: Language;
}

export const OnboardingFlow: React.FC<OnboardingFlowProps> = ({
  onComplete,
  onLoginClick,
  language,
}) => {
  const [currentSlide, setCurrentSlide] = useState(0);

  const t = TRANSLATIONS[language];

  const slides = [
    {
      title: language === 'hi' ? 'सभी प्रोडक्ट्स एक ही स्थान पर' : 'All Your Products in One Place',
      desc: language === 'hi' ? 'अपने घरेलू एवं निजी उपकरणों को डिजिटल रूप से व्यवस्थित करें।' : 'Manage your home and personal products digitally with all invoices & details.',
      icon: Smartphone,
      accent: 'from-indigo-600 to-purple-600',
      badge: 'Product Hub',
      highlight: '24+ Categories Supported',
    },
    {
      title: language === 'hi' ? 'कभी न चूकें वारंटी' : 'Never Miss a Warranty',
      desc: language === 'hi' ? 'वारंटी समाप्त होने से पहले समय पर ऑटोमैटिक अलर्ट व रिमाइंडर प्राप्त करें।' : 'Get automatic smart reminders before your warranty and AMC policies expire.',
      icon: Bell,
      accent: 'from-purple-600 to-pink-600',
      badge: 'Smart Reminders',
      highlight: 'Zero Bill-Shock Guarantee',
    },
    {
      title: language === 'hi' ? 'हर खर्च का सटीक हिसाब' : 'Track Every Expense',
      desc: language === 'hi' ? 'सर्विस, रिपेयर, इंस्टॉलेशन व पार्ट्स पर होने वाले हर खर्च की ट्रैकिंग।' : 'Know exactly how much you spend on every single product throughout its lifetime.',
      icon: Receipt,
      accent: 'from-indigo-600 to-blue-600',
      badge: 'TCO & Analytics',
      highlight: 'Total Cost of Ownership',
    },
  ];

  const slide = slides[currentSlide];
  const IconComponent = slide.icon;

  return (
    <div className="min-h-full flex flex-col justify-between p-6 bg-gradient-to-b from-indigo-950 via-slate-900 to-slate-950 text-white relative overflow-hidden">
      {/* Background radial glow */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-80 h-80 rounded-full bg-indigo-600/25 blur-3xl pointer-events-none" />
      <div className="absolute bottom-10 right-0 w-64 h-64 rounded-full bg-purple-600/20 blur-3xl pointer-events-none" />

      {/* Top Bar: Brand Logo & Skip */}
      <div className="relative z-10 flex items-center justify-between pt-2">
        <div className="flex items-center space-x-2.5">
          <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-indigo-500 to-purple-500 p-0.5 shadow-lg shadow-indigo-500/30 flex items-center justify-center">
            <div className="w-full h-full bg-slate-950 rounded-[14px] flex items-center justify-center text-indigo-400">
              <Shield className="w-5 h-5 fill-indigo-400/20" />
            </div>
          </div>
          <div>
            <h1 className="text-xl font-black font-['Outfit',sans-serif] tracking-tight text-white leading-none">
              Warranty<span className="text-indigo-400">X</span>
            </h1>
            <p className="text-[10px] text-indigo-200/70 font-medium mt-0.5">Mobile Asset Hub</p>
          </div>
        </div>

        {currentSlide < 2 && (
          <button
            onClick={onComplete}
            className="text-xs font-semibold text-slate-400 hover:text-white px-3 py-1 rounded-full bg-slate-800/60 border border-slate-700/50 transition-colors cursor-pointer"
          >
            Skip
          </button>
        )}
      </div>

      {/* Center Illustrated Hero Card */}
      <div className="relative z-10 my-auto py-6 flex flex-col items-center text-center">
        {/* Dynamic Graphic Mockup */}
        <div className="relative mb-8">
          <div className={`w-44 h-44 rounded-3xl bg-gradient-to-tr ${slide.accent} p-1 shadow-2xl shadow-indigo-500/30 flex items-center justify-center transition-all duration-500`}>
            <div className="w-full h-full bg-slate-900/90 backdrop-blur-md rounded-[22px] flex flex-col items-center justify-center p-4 text-center">
              <div className="w-16 h-16 rounded-2xl bg-indigo-500/20 text-indigo-300 border border-indigo-500/40 flex items-center justify-center mb-3">
                <IconComponent className="w-8 h-8" />
              </div>
              <span className="text-[11px] font-bold uppercase tracking-wider text-indigo-300 bg-indigo-950/80 px-2.5 py-0.5 rounded-full border border-indigo-800/60">
                {slide.badge}
              </span>
            </div>
          </div>

          {/* Floating badge */}
          <div className="absolute -bottom-3 -right-2 px-3 py-1.5 rounded-xl bg-slate-800/95 border border-slate-700 shadow-xl flex items-center space-x-1.5 text-[11px] font-bold text-emerald-400">
            <CheckCircle className="w-3.5 h-3.5" />
            <span>{slide.highlight}</span>
          </div>
        </div>

        {/* Text Content */}
        <div className="space-y-3 max-w-xs">
          <h2 className="text-2xl font-black font-['Outfit',sans-serif] text-white tracking-tight leading-tight">
            {slide.title}
          </h2>
          <p className="text-xs sm:text-sm text-slate-300 font-normal leading-relaxed">
            {slide.desc}
          </p>
        </div>

        {/* Tagline snippet */}
        <div className="mt-6 px-4 py-2 rounded-2xl bg-indigo-950/60 border border-indigo-800/40 text-[11px] font-medium text-indigo-200">
          ✨ {t.tagline}
        </div>
      </div>

      {/* Bottom Controls: Dots, Next, Get Started & Login */}
      <div className="relative z-10 space-y-4 pb-4">
        {/* Pagination dots */}
        <div className="flex justify-center items-center space-x-2">
          {slides.map((_, idx) => (
            <button
              key={idx}
              onClick={() => setCurrentSlide(idx)}
              className={`h-2 rounded-full transition-all duration-300 cursor-pointer ${
                currentSlide === idx ? 'w-8 bg-indigo-400 shadow-sm shadow-indigo-400' : 'w-2 bg-slate-700'
              }`}
              aria-label={`Slide ${idx + 1}`}
            />
          ))}
        </div>

        {/* Action Buttons */}
        {currentSlide < 2 ? (
          <button
            id="onboarding-next-btn"
            onClick={() => setCurrentSlide(currentSlide + 1)}
            className="w-full py-3.5 rounded-2xl bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white font-bold text-sm shadow-lg shadow-indigo-600/40 flex items-center justify-center space-x-2 transition-all active:scale-95 cursor-pointer"
          >
            <span>Continue</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        ) : (
          <div className="space-y-2.5">
            <button
              id="onboarding-get-started-btn"
              onClick={onComplete}
              className="w-full py-3.5 rounded-2xl bg-gradient-to-r from-indigo-600 via-indigo-500 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white font-black text-sm tracking-wide shadow-xl shadow-indigo-600/40 flex items-center justify-center space-x-2 transition-all active:scale-95 cursor-pointer"
            >
              <Sparkles className="w-4 h-4 text-amber-300" />
              <span>{t.getStarted}</span>
            </button>

            <button
              id="onboarding-login-btn"
              onClick={onLoginClick}
              className="w-full py-3 rounded-2xl bg-slate-800/80 hover:bg-slate-800 text-slate-200 text-xs font-bold border border-slate-700 transition-colors flex items-center justify-center cursor-pointer"
            >
              <span>{t.login}</span>
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
