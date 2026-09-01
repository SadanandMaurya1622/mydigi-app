import React, { useState } from 'react';
import { 
  X, 
  Download, 
  Copy, 
  Check
} from 'lucide-react';
import { ProductItem } from '../types';
import { Language } from '../utils/translations';
import confetti from 'canvas-confetti';

interface QRCodeModalProps {
  isOpen: boolean;
  product: ProductItem | null;
  onClose: () => void;
  language: Language;
}

export const QRCodeModal: React.FC<QRCodeModalProps> = ({
  isOpen,
  product,
  onClose,
}) => {
  const [copied, setCopied] = useState(false);

  if (!isOpen || !product) return null;

  const qrData = `https://warrantyx.app/verify/${product.id}?serial=${product.serialNumber}`;

  const handleCopyLink = () => {
    navigator.clipboard?.writeText(qrData);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-xs animate-in fade-in">
      <div className="relative w-full max-w-sm flex flex-col bg-white dark:bg-slate-900 rounded-3xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden text-center p-6 space-y-4">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-2 rounded-full text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 cursor-pointer"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Title & Product Info */}
        <div className="space-y-1">
          <span className="text-[10px] font-bold uppercase tracking-wider text-indigo-600 dark:text-indigo-400">
            WarrantyX Asset Passport
          </span>
          <h3 className="text-lg font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
            {product.name}
          </h3>
          <p className="text-xs text-slate-500 font-mono">
            Serial: {product.serialNumber}
          </p>
        </div>

        {/* QR Code Container (Matching Screen 13) */}
        <div className="p-5 rounded-3xl bg-white dark:bg-white border-2 border-slate-200 shadow-inner inline-block mx-auto">
          <svg className="w-44 h-44 mx-auto" viewBox="0 0 100 100" fill="none">
            {/* SVG stylized QR code matrix */}
            <rect width="100" height="100" fill="white" />
            {/* Corner Markers */}
            <rect x="5" y="5" width="28" height="28" fill="#1e1b4b" rx="4" />
            <rect x="9" y="9" width="20" height="20" fill="white" rx="2" />
            <rect x="13" y="13" width="12" height="12" fill="#4338ca" rx="2" />

            <rect x="67" y="5" width="28" height="28" fill="#1e1b4b" rx="4" />
            <rect x="71" y="9" width="20" height="20" fill="white" rx="2" />
            <rect x="75" y="13" width="12" height="12" fill="#4338ca" rx="2" />

            <rect x="5" y="67" width="28" height="28" fill="#1e1b4b" rx="4" />
            <rect x="9" y="71" width="20" height="20" fill="white" rx="2" />
            <rect x="13" y="75" width="12" height="12" fill="#4338ca" rx="2" />

            {/* Pattern Dots */}
            <circle cx="42" cy="15" r="3" fill="#1e1b4b" />
            <circle cx="54" cy="15" r="3" fill="#1e1b4b" />
            <circle cx="48" cy="25" r="3" fill="#4338ca" />
            <circle cx="15" cy="45" r="3" fill="#1e1b4b" />
            <circle cx="25" cy="45" r="3" fill="#1e1b4b" />
            <circle cx="20" cy="55" r="3" fill="#4338ca" />
            <circle cx="80" cy="45" r="3" fill="#1e1b4b" />
            <circle cx="85" cy="55" r="3" fill="#4338ca" />
            <circle cx="45" cy="45" r="4" fill="#4338ca" />
            <circle cx="55" cy="55" r="4" fill="#1e1b4b" />
            <circle cx="40" cy="65" r="3" fill="#1e1b4b" />
            <circle cx="50" cy="75" r="3" fill="#4338ca" />
            <circle cx="60" cy="85" r="3" fill="#1e1b4b" />
            <circle cx="75" cy="75" r="3" fill="#1e1b4b" />
            <circle cx="85" cy="85" r="3" fill="#4338ca" />
          </svg>
        </div>

        <p className="text-[11px] text-slate-500 max-w-xs mx-auto">
          Scan this sticker to immediately view warranty, invoices, and schedule technician visits.
        </p>

        {/* Action Buttons (Matching Screen 13) */}
        <div className="grid grid-cols-2 gap-2 pt-2 text-xs font-bold">
          <button
            onClick={() => {
              confetti({ particleCount: 30 });
              alert('Downloading high-res QR printable asset...');
            }}
            className="py-2.5 px-3 rounded-2xl bg-indigo-50 dark:bg-indigo-950/60 text-indigo-600 dark:text-indigo-400 hover:bg-indigo-100 flex items-center justify-center space-x-1.5 cursor-pointer"
          >
            <Download className="w-3.5 h-3.5" />
            <span>Save Sticker</span>
          </button>

          <button
            onClick={handleCopyLink}
            className="py-2.5 px-3 rounded-2xl bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-slate-200 flex items-center justify-center space-x-1.5 cursor-pointer"
          >
            {copied ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
            <span>{copied ? 'Copied!' : 'Copy Link'}</span>
          </button>
        </div>

        <button
          onClick={onClose}
          className="w-full py-2.5 rounded-2xl bg-indigo-600 text-white font-bold text-xs shadow-md shadow-indigo-600/30 cursor-pointer"
        >
          Done
        </button>
      </div>
    </div>
  );
};
