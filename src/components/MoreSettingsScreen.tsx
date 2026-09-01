import React, { useState } from 'react';
import { 
  FileText, 
  ShieldCheck, 
  Wrench, 
  BarChart3, 
  Users, 
  Cloud, 
  Globe, 
  Moon, 
  Sun, 
  LogOut, 
  ChevronRight, 
  Crown, 
  Bell,
  Smartphone
} from 'lucide-react';
import { FamilyMember } from '../types';
import { Language, TRANSLATIONS } from '../utils/translations';
import { FlutterExportModal } from './FlutterExportModal';
import confetti from 'canvas-confetti';

interface MoreSettingsScreenProps {
  userName: string;
  userEmail: string;
  familyMembers: FamilyMember[];
  language: Language;
  onLanguageChange: (lang: Language) => void;
  isDark: boolean;
  onToggleTheme: () => void;
  onOpenVault: () => void;
  onOpenAMC: () => void;
  onOpenClaims: () => void;
  onOpenReports: () => void;
  onOpenReminders: () => void;
  onLogout: () => void;
}

export const MoreSettingsScreen: React.FC<MoreSettingsScreenProps> = ({
  userName,
  userEmail,
  familyMembers,
  language,
  onLanguageChange,
  isDark,
  onToggleTheme,
  onOpenVault,
  onOpenAMC,
  onOpenClaims,
  onOpenReports,
  onOpenReminders,
  onLogout,
}) => {
  const t = TRANSLATIONS[language];
  const [showFamilyModal, setShowFamilyModal] = useState(false);
  const [showFlutterModal, setShowFlutterModal] = useState(false);
  const [syncStatus, setSyncStatus] = useState('Sync complete');
  const [isSyncing, setIsSyncing] = useState(false);

  const handleTriggerSync = () => {
    setIsSyncing(true);
    setSyncStatus('Backing up encrypted vault...');
    setTimeout(() => {
      setIsSyncing(false);
      setSyncStatus('Last synced just now');
      confetti({ particleCount: 30 });
    }, 1200);
  };

  return (
    <div className="p-4 sm:p-6 space-y-4 pb-24 relative min-h-full">
      {/* 1. Profile Hero Card (Matching Screen 15) */}
      <div className="p-4 sm:p-5 rounded-3xl bg-gradient-to-br from-indigo-700 via-indigo-600 to-purple-800 text-white shadow-xl shadow-indigo-600/25 space-y-3">
        <div className="flex items-center space-x-3.5">
          <div className="w-14 h-14 rounded-2xl bg-white/20 backdrop-blur-md border border-white/30 flex items-center justify-center text-xl font-black font-['Outfit',sans-serif]">
            {userName.charAt(0)}
          </div>
          <div className="space-y-0.5">
            <div className="flex items-center space-x-1.5">
              <h2 className="text-base sm:text-lg font-black font-['Outfit',sans-serif]">{userName}</h2>
              <span className="px-2 py-0.5 rounded-full bg-amber-400 text-slate-950 font-black text-[10px] flex items-center space-x-0.5">
                <Crown className="w-3 h-3 fill-slate-950" />
                <span>PRO</span>
              </span>
            </div>
            <p className="text-xs text-indigo-200">{userEmail}</p>
          </div>
        </div>

        <div className="pt-2 border-t border-indigo-500/50 flex items-center justify-between text-xs text-indigo-200">
          <span>WarrantyX Cloud Vault Active</span>
          <span className="font-semibold text-emerald-300">24/24 Products Protected</span>
        </div>
      </div>

      {/* 2. Management Modules Section */}
      <div className="space-y-1.5">
        <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 px-1">
          Asset Hub
        </span>

        <div className="rounded-3xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs divide-y divide-slate-100 dark:divide-slate-800 overflow-hidden text-xs">
          <button
            onClick={onOpenVault}
            className="w-full p-3.5 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer"
          >
            <div className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-indigo-50 dark:bg-indigo-950/80 text-indigo-600 dark:text-indigo-400 flex items-center justify-center">
                <FileText className="w-4 h-4" />
              </div>
              <div className="text-left">
                <span className="font-bold text-slate-900 dark:text-white block">{t.invoiceVault}</span>
                <span className="text-[11px] text-slate-500">Bills, receipts & guarantee cards</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </button>

          <button
            onClick={onOpenAMC}
            className="w-full p-3.5 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer"
          >
            <div className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-teal-50 dark:bg-teal-950/80 text-teal-600 dark:text-teal-400 flex items-center justify-center">
                <ShieldCheck className="w-4 h-4" />
              </div>
              <div className="text-left">
                <span className="font-bold text-slate-900 dark:text-white block">{t.amcTracker} & Insurance</span>
                <span className="text-[11px] text-slate-500">Annual maintenance contracts</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </button>

          <button
            onClick={onOpenClaims}
            className="w-full p-3.5 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer"
          >
            <div className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-purple-50 dark:bg-purple-950/80 text-purple-600 dark:text-purple-400 flex items-center justify-center">
                <Wrench className="w-4 h-4" />
              </div>
              <div className="text-left">
                <span className="font-bold text-slate-900 dark:text-white block">Warranty Claims & Service</span>
                <span className="text-[11px] text-slate-500">Track authorized brand repairs</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </button>

          <button
            onClick={onOpenReports}
            className="w-full p-3.5 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer"
          >
            <div className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-amber-50 dark:bg-amber-950/80 text-amber-600 dark:text-amber-400 flex items-center justify-center">
                <BarChart3 className="w-4 h-4" />
              </div>
              <div className="text-left">
                <span className="font-bold text-slate-900 dark:text-white block">{t.expenseAnalytics} & Reports</span>
                <span className="text-[11px] text-slate-500">Export CSV / PDF valuation sheets</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </button>

          <button
            onClick={() => setShowFamilyModal(true)}
            className="w-full p-3.5 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer"
          >
            <div className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-pink-50 dark:bg-pink-950/80 text-pink-600 dark:text-pink-400 flex items-center justify-center">
                <Users className="w-4 h-4" />
              </div>
              <div className="text-left">
                <span className="font-bold text-slate-900 dark:text-white block">{t.familyMembers}</span>
                <span className="text-[11px] text-slate-500">{familyMembers.length} members connected</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </button>
        </div>
      </div>

      {/* 3. Cloud, Preferences & Language Settings */}
      <div className="space-y-1.5">
        <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 px-1">
          {t.settings}
        </span>

        <div className="rounded-3xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs divide-y divide-slate-100 dark:divide-slate-800 overflow-hidden text-xs">
          {/* Cloud Sync */}
          <div className="p-3.5 flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-blue-50 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center">
                <Cloud className="w-4 h-4" />
              </div>
              <div>
                <span className="font-bold text-slate-900 dark:text-white block">{t.backupRestore}</span>
                <span className="text-[11px] text-slate-500">{syncStatus}</span>
              </div>
            </div>
            <button
              onClick={handleTriggerSync}
              disabled={isSyncing}
              className="px-3 py-1 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 text-slate-700 dark:text-slate-300 font-bold text-xs cursor-pointer"
            >
              {isSyncing ? 'Syncing...' : 'Sync Now'}
            </button>
          </div>

          {/* Language Switcher */}
          <div className="p-3.5 flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-emerald-50 dark:bg-emerald-950/80 text-emerald-600 dark:text-emerald-400 flex items-center justify-center">
                <Globe className="w-4 h-4" />
              </div>
              <div>
                <span className="font-bold text-slate-900 dark:text-white block">{t.language}</span>
                <span className="text-[11px] text-slate-500">{language === 'en' ? 'English' : 'हिंदी (Hindi)'}</span>
              </div>
            </div>
            <div className="flex items-center space-x-1 bg-slate-100 dark:bg-slate-800 p-1 rounded-xl">
              <button
                onClick={() => onLanguageChange('en')}
                className={`px-2.5 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer ${
                  language === 'en' ? 'bg-indigo-600 text-white' : 'text-slate-600 dark:text-slate-400'
                }`}
              >
                EN
              </button>
              <button
                onClick={() => onLanguageChange('hi')}
                className={`px-2.5 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer ${
                  language === 'hi' ? 'bg-indigo-600 text-white' : 'text-slate-600 dark:text-slate-400'
                }`}
              >
                हिंदी
              </button>
            </div>
          </div>

          {/* Dark Mode Toggle */}
          <div className="p-3.5 flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-indigo-50 dark:bg-indigo-950/80 text-indigo-600 dark:text-indigo-400 flex items-center justify-center">
                {isDark ? <Moon className="w-4 h-4" /> : <Sun className="w-4 h-4" />}
              </div>
              <div>
                <span className="font-bold text-slate-900 dark:text-white block">Appearance</span>
                <span className="text-[11px] text-slate-500">{isDark ? 'Dark Mode' : 'Light Mode'}</span>
              </div>
            </div>
            <button
              onClick={onToggleTheme}
              className="p-2 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 font-bold text-xs hover:bg-slate-200 cursor-pointer"
            >
              Toggle
            </button>
          </div>

          {/* Warranty Reminders */}
          <button
            onClick={onOpenReminders}
            className="w-full p-3.5 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer"
          >
            <div className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-rose-50 dark:bg-rose-950/80 text-rose-600 dark:text-rose-400 flex items-center justify-center">
                <Bell className="w-4 h-4" />
              </div>
              <div className="text-left">
                <span className="font-bold text-slate-900 dark:text-white block">{t.warrantyReminders}</span>
                <span className="text-[11px] text-slate-500">180, 90, 30, 7 days notifications</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </button>

          {/* Flutter App Source Code Exporter */}
          <button
            onClick={() => setShowFlutterModal(true)}
            className="w-full p-3.5 flex items-center justify-between hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer bg-gradient-to-r from-blue-500/5 to-cyan-500/5"
          >
            <div className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-blue-50 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center border border-blue-200/50 dark:border-blue-800/50">
                <Smartphone className="w-4 h-4" />
              </div>
              <div className="text-left">
                <span className="font-bold text-slate-900 dark:text-white block">📱 Flutter & Dart Code Export</span>
                <span className="text-[11px] text-blue-600 dark:text-blue-400 font-semibold">Ready for Android Studio & VS Code</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-blue-500" />
          </button>
        </div>
      </div>

      {/* 4. Logout Action */}
      <div className="pt-2">
        <button
          onClick={onLogout}
          className="w-full py-3 rounded-2xl bg-rose-50 dark:bg-rose-950/50 hover:bg-rose-100 text-rose-600 dark:text-rose-400 font-bold text-xs border border-rose-200 dark:border-rose-900/50 transition-colors flex items-center justify-center space-x-2 cursor-pointer"
        >
          <LogOut className="w-4 h-4" />
          <span>{t.logout}</span>
        </button>
      </div>

      {/* Flutter Export Modal */}
      <FlutterExportModal
        isOpen={showFlutterModal}
        onClose={() => setShowFlutterModal(false)}
      />

      {/* Family Sharing Modal */}
      {showFamilyModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-xs">
          <div className="w-full max-w-sm bg-white dark:bg-slate-900 rounded-3xl p-5 border border-slate-200 dark:border-slate-800 space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-bold text-slate-900 dark:text-white">Family Asset Sharing</h3>
              <button onClick={() => setShowFamilyModal(false)} className="text-slate-400 hover:text-slate-600 cursor-pointer">✕</button>
            </div>

            <div className="space-y-2">
              {familyMembers.map((m) => (
                <div key={m.id} className="p-3 rounded-2xl bg-slate-50 dark:bg-slate-800 flex items-center justify-between">
                  <div>
                    <h4 className="text-xs font-bold text-slate-900 dark:text-white">{m.name}</h4>
                    <p className="text-[10px] text-slate-500">{m.relation} • {m.email}</p>
                  </div>
                  <span className="text-[10px] px-2 py-0.5 rounded-full bg-indigo-50 dark:bg-indigo-950 text-indigo-600 dark:text-indigo-400 font-bold">
                    {m.role}
                  </span>
                </div>
              ))}
            </div>

            <button
              onClick={() => {
                alert('Invite link sent to family WhatsApp / Email!');
                setShowFamilyModal(false);
              }}
              className="w-full py-2.5 rounded-xl bg-indigo-600 text-white font-bold text-xs shadow-md shadow-indigo-600/30 cursor-pointer"
            >
              + Invite Family Member
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
