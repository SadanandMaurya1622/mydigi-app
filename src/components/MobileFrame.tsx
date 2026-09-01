import React, { useState } from 'react';
import { Smartphone, Monitor, Shield, Sparkles, Languages, Moon, Sun } from 'lucide-react';
import { Language } from '../utils/translations';

export interface MobileFrameProps {
  children: React.ReactNode;
  isPhoneFrame?: boolean;
  onToggleFrame?: () => void;
  language?: Language;
  onToggleLanguage?: () => void;
  isDark?: boolean;
  onToggleDark?: () => void;
  onOpenQuickScan?: () => void;
}

export const MobileFrame: React.FC<MobileFrameProps> = ({
  children,
  isPhoneFrame: propIsPhoneFrame,
  onToggleFrame,
  language = 'en',
  onToggleLanguage,
  isDark = false,
  onToggleDark,
  onOpenQuickScan,
}) => {
  const [internalPhoneFrame, setInternalPhoneFrame] = useState(true);
  const isPhone = propIsPhoneFrame !== undefined ? propIsPhoneFrame : internalPhoneFrame;

  const handleToggleFrame = () => {
    if (onToggleFrame) {
      onToggleFrame();
    } else {
      setInternalPhoneFrame(!internalPhoneFrame);
    }
  };

  return (
    <div className={`min-h-screen w-full ${isDark ? 'bg-slate-950 text-slate-100' : 'bg-slate-900 text-slate-900'} transition-colors flex flex-col items-center justify-start p-0 sm:p-4 select-none`}>
      {/* Top Floating Control Bar */}
      <header className="w-full max-w-4xl mb-3 hidden sm:flex items-center justify-between px-4 py-2.5 rounded-2xl bg-slate-900/90 backdrop-blur-md border border-slate-800 text-white shadow-lg">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 rounded-xl bg-gradient-to-tr from-indigo-600 via-purple-600 to-indigo-500 flex items-center justify-center shadow-md shadow-indigo-500/30">
            <Shield className="w-4 h-4 text-white fill-white/20" />
          </div>
          <div>
            <div className="flex items-center space-x-2">
              <span className="font-extrabold text-base tracking-tight font-['Outfit',sans-serif]">Warranty<span className="text-indigo-400">X</span></span>
              <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30">
                Mobile Suite
              </span>
            </div>
            <p className="text-[11px] text-slate-400 leading-none mt-0.5">
              {language === 'hi' ? 'अपने हर प्रोडक्ट का खर्चा और वारंटी, एक ही ऐप में' : 'Apne har product ka kharcha aur warranty, ek hi app mein'}
            </p>
          </div>
        </div>

        <div className="flex items-center space-x-2.5">
          {/* Quick AI OCR Scanner Button */}
          {onOpenQuickScan && (
            <button
              id="desktop-ai-scan-btn"
              onClick={onOpenQuickScan}
              className="flex items-center space-x-1.5 px-3 py-1.5 rounded-xl bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white text-xs font-bold shadow-md shadow-indigo-600/30 transition-all cursor-pointer"
            >
              <Sparkles className="w-3.5 h-3.5 text-amber-300" />
              <span>AI Bill Scan</span>
            </button>
          )}

          {/* Language Toggle */}
          {onToggleLanguage && (
            <button
              id="lang-toggle-btn"
              onClick={onToggleLanguage}
              className="flex items-center space-x-1 px-2.5 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold border border-slate-700 transition-colors cursor-pointer"
              title="Switch Language (EN / हिंदी)"
            >
              <Languages className="w-3.5 h-3.5 text-indigo-400" />
              <span>{language === 'en' ? 'हिन्दी' : 'English'}</span>
            </button>
          )}

          {/* Dark / Light Mode Toggle */}
          {onToggleDark && (
            <button
              id="dark-toggle-btn"
              onClick={onToggleDark}
              className="p-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 transition-colors cursor-pointer"
              title="Toggle Theme"
            >
              {isDark ? <Sun className="w-4 h-4 text-amber-400" /> : <Moon className="w-4 h-4 text-indigo-400" />}
            </button>
          )}

          {/* Phone Frame vs Full Responsive View Toggle */}
          <button
            id="frame-toggle-btn"
            onClick={handleToggleFrame}
            className="flex items-center space-x-1.5 px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold border border-slate-700 transition-colors cursor-pointer"
            title="Toggle Phone Frame"
          >
            {isPhone ? (
              <>
                <Monitor className="w-3.5 h-3.5 text-indigo-400" />
                <span>Full View</span>
              </>
            ) : (
              <>
                <Smartphone className="w-3.5 h-3.5 text-indigo-400" />
                <span>Phone Frame</span>
              </>
            )}
          </button>
        </div>
      </header>

      {/* Main Container: either Phone Mockup or Responsive Container */}
      <main className="w-full flex justify-center items-start">
        {isPhone ? (
          <div className="relative w-full max-w-[420px] h-[860px] max-h-[95vh] rounded-[48px] p-3 bg-slate-950 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.9),0_0_0_10px_#1e1b4b,0_0_0_12px_#312e81] border-4 border-slate-800 flex flex-col overflow-hidden transition-all duration-300">
            {/* Dynamic Island */}
            <div className="absolute top-3.5 left-1/2 -translate-x-1/2 z-50 flex items-center justify-between px-3 w-28 h-5.5 bg-black rounded-full shadow-inner border border-slate-800">
              <div className="w-2 h-2 rounded-full bg-slate-900 border border-slate-700" />
              <div className="w-2 h-2 rounded-full bg-indigo-950/80 ring-1 ring-indigo-500/40" />
            </div>

            {/* Status Bar */}
            <div className="relative z-40 flex items-center justify-between px-6 pt-1 pb-1.5 text-[11px] font-bold tracking-tight text-slate-900 dark:text-white pointer-events-none">
              <span>9:41</span>
              <div className="flex items-center space-x-1.5 text-xs">
                <span className="text-[10px]">5G</span>
                <div className="w-4.5 h-2.5 border border-current rounded-sm p-0.5 flex items-center">
                  <div className="w-full h-full bg-current rounded-2xs" />
                </div>
              </div>
            </div>

            {/* Mobile App Canvas Screen */}
            <div className={`relative w-full h-[calc(100%-24px)] rounded-[34px] overflow-hidden flex flex-col ${isDark ? 'bg-slate-950 text-slate-100' : 'bg-slate-50 text-slate-900'}`}>
              <div className="flex-1 overflow-y-auto overflow-x-hidden flex flex-col scroll-smooth">
                {children}
              </div>

              {/* iOS Home Bar Indicator */}
              <div className="w-full py-1 flex justify-center items-center bg-transparent pointer-events-none shrink-0">
                <div className="w-28 h-1 rounded-full bg-slate-400/60 dark:bg-slate-600/60" />
              </div>
            </div>
          </div>
        ) : (
          <div className={`w-full max-w-2xl min-h-[820px] rounded-3xl overflow-hidden shadow-2xl border ${isDark ? 'border-slate-800 bg-slate-950 text-slate-100' : 'border-slate-200 bg-slate-50 text-slate-900'} flex flex-col`}>
            {children}
          </div>
        )}
      </main>
    </div>
  );
};
