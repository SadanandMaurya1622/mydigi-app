import React, { useState, useEffect } from 'react';
import { 
  X, 
  Camera, 
  Upload, 
  Sparkles, 
  FileText, 
  CheckCircle, 
  RefreshCw, 
  Scan
} from 'lucide-react';
import { ProductItem } from '../types';
import { Language, TRANSLATIONS } from '../utils/translations';
import confetti from 'canvas-confetti';

interface AIScannerModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirmExtractedProduct: (extracted: Partial<ProductItem>) => void;
  language: Language;
}

export const AIScannerModal: React.FC<AIScannerModalProps> = ({
  isOpen,
  onClose,
  onConfirmExtractedProduct,
  language,
}) => {
  const t = TRANSLATIONS[language];

  const [scanState, setScanState] = useState<'viewfinder' | 'scanning' | 'extracted'>('viewfinder');

  // Simulated Extracted Data (Matching Screen 7 mockup)
  const [extractedData] = useState({
    product: 'LG Refrigerator 360L',
    category: 'Appliances' as const,
    brand: 'LG',
    purchaseDate: '20 Aug 2026',
    amount: 38500,
    seller: 'XYZ Electronics',
    invoiceNo: 'INV-2026-0897',
    warrantyPeriod: '2 Years Comprehensive',
    serialNo: 'LGRF3456GH',
  });

  useEffect(() => {
    if (isOpen) {
      setScanState('viewfinder');
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleStartScan = () => {
    setScanState('scanning');
    setTimeout(() => {
      setScanState('extracted');
      confetti({ particleCount: 50, spread: 60 });
    }, 1800);
  };

  const handleConfirm = () => {
    const newProductPartial: Partial<ProductItem> = {
      name: extractedData.product,
      category: extractedData.category,
      brand: extractedData.brand,
      purchaseDate: extractedData.purchaseDate,
      purchasePrice: extractedData.amount,
      sellerName: extractedData.seller,
      invoiceNumber: extractedData.invoiceNo,
      warrantyPeriod: extractedData.warrantyPeriod,
      serialNumber: extractedData.serialNo,
      warrantyStartDate: extractedData.purchaseDate,
      warrantyEndDate: '20 Aug 2028',
      warrantyStatus: 'Active',
      daysRemaining: 720,
      imageUrl: 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80',
    };

    onConfirmExtractedProduct(newProductPartial);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/85 backdrop-blur-xs animate-in fade-in">
      <div className="relative w-full max-w-md max-h-[92vh] flex flex-col bg-white dark:bg-slate-900 rounded-3xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
        {/* Top Bar */}
        <div className="flex items-center justify-between p-5 pb-3 border-b border-slate-100 dark:border-slate-800">
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 rounded-xl bg-indigo-50 dark:bg-indigo-950/80 text-indigo-600 dark:text-indigo-400 flex items-center justify-center">
              <Sparkles className="w-4 h-4" />
            </div>
            <div>
              <h3 className="text-base font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                {t.scanInvoiceAI}
              </h3>
              <p className="text-[11px] text-slate-500">AI OCR auto-extracts warranty & price</p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-2 rounded-full text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 cursor-pointer"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-5 space-y-4 text-xs">
          {/* Scanner Viewfinder / Document simulation */}
          {scanState !== 'extracted' && (
            <div className="relative w-full h-72 rounded-2xl bg-slate-950 border border-slate-800 overflow-hidden flex flex-col items-center justify-center text-white">
              {/* Receipt sample background */}
              <div className="absolute inset-4 bg-slate-900/90 rounded-xl p-4 border border-slate-700/80 font-mono text-[10px] text-slate-300 opacity-70 overflow-hidden flex flex-col justify-between select-none">
                <div className="text-center pb-2 border-b border-dashed border-slate-600">
                  <div className="font-bold text-xs text-white">TAX INVOICE & CASH RECEIPT</div>
                  <div className="text-[9px] text-slate-400">XYZ Electronics Mega Store • GSTIN: 27AABCT3529K1Z4</div>
                </div>
                <div className="space-y-1 py-2">
                  <div className="flex justify-between">
                    <span>ITEM: LG Refrigerator 360L</span>
                    <span>₹38,500.00</span>
                  </div>
                  <div className="flex justify-between text-slate-400">
                    <span>SERIAL: LGRF3456GH</span>
                    <span>WTY: 2 YR</span>
                  </div>
                  <div className="flex justify-between text-slate-400">
                    <span>DATE: 20-AUG-2026</span>
                    <span>INV: 0897</span>
                  </div>
                </div>
                <div className="text-center pt-2 border-t border-dashed border-slate-600 text-[9px] text-slate-400">
                  THANK YOU FOR SHOPPING! PRESERVE FOR WARRANTY
                </div>
              </div>

              {/* Viewfinder Target Box with glowing corners */}
              <div className="relative z-10 w-60 h-48 border-2 border-indigo-500/60 rounded-2xl flex items-center justify-center">
                {/* Corner markers */}
                <div className="absolute -top-1 -left-1 w-4 h-4 border-t-3 border-l-3 border-indigo-400 rounded-tl-lg" />
                <div className="absolute -top-1 -right-1 w-4 h-4 border-t-3 border-r-3 border-indigo-400 rounded-tr-lg" />
                <div className="absolute -bottom-1 -left-1 w-4 h-4 border-b-3 border-l-3 border-indigo-400 rounded-bl-lg" />
                <div className="absolute -bottom-1 -right-1 w-4 h-4 border-b-3 border-r-3 border-indigo-400 rounded-br-lg" />

                {/* Animated Laser Scanning Line */}
                {scanState === 'scanning' && (
                  <div className="absolute left-0 right-0 h-1 bg-gradient-to-r from-transparent via-cyan-400 to-transparent shadow-[0_0_15px_#22d3ee] animate-pulse transition-all duration-300 top-1/2 -translate-y-1/2" />
                )}

                {scanState === 'viewfinder' && (
                  <div className="text-center p-3 bg-black/60 rounded-xl backdrop-blur-xs border border-white/10">
                    <Scan className="w-6 h-6 text-indigo-400 mx-auto mb-1" />
                    <span className="text-[11px] font-bold text-white block">Align invoice inside frame</span>
                  </div>
                )}

                {scanState === 'scanning' && (
                  <div className="text-center p-3 bg-black/80 rounded-xl backdrop-blur-md border border-indigo-500/40 animate-pulse">
                    <Sparkles className="w-6 h-6 text-amber-400 mx-auto mb-1 animate-spin" />
                    <span className="text-[11px] font-black text-white block">AI OCR Scanning...</span>
                    <span className="text-[9px] text-indigo-300">Extracting fields with Vision AI</span>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Action Trigger Buttons for Scanning */}
          {scanState === 'viewfinder' && (
            <div className="space-y-2">
              <button
                onClick={handleStartScan}
                className="w-full py-3 rounded-2xl bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white font-bold text-xs shadow-lg shadow-indigo-600/30 flex items-center justify-center space-x-2 cursor-pointer"
              >
                <Camera className="w-4 h-4" />
                <span>Snap & Scan Document</span>
              </button>

              <div className="grid grid-cols-2 gap-2">
                <button
                  onClick={handleStartScan}
                  className="py-2.5 px-3 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-700 dark:text-slate-300 font-bold text-xs hover:bg-slate-100 flex items-center justify-center space-x-1.5 cursor-pointer"
                >
                  <Upload className="w-4 h-4 text-purple-500" />
                  <span>Choose from Gallery</span>
                </button>

                <button
                  onClick={handleStartScan}
                  className="py-2.5 px-3 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-700 dark:text-slate-300 font-bold text-xs hover:bg-slate-100 flex items-center justify-center space-x-1.5 cursor-pointer"
                >
                  <FileText className="w-4 h-4 text-indigo-500" />
                  <span>Upload PDF Bill</span>
                </button>
              </div>
            </div>
          )}

          {/* Extracted Details Result Card (Matching Screen 7) */}
          {scanState === 'extracted' && (
            <div className="space-y-4 animate-in fade-in zoom-in-95">
              <div className="p-4 rounded-2xl bg-emerald-50 dark:bg-emerald-950/60 border border-emerald-200 dark:border-emerald-800 flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <CheckCircle className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
                  <div>
                    <h4 className="text-xs font-black text-emerald-950 dark:text-emerald-200">
                      AI Scanning Result
                    </h4>
                    <p className="text-[10px] text-emerald-800 dark:text-emerald-300">
                      100% Accuracy • All key warranty fields parsed
                    </p>
                  </div>
                </div>
                <span className="px-2 py-0.5 rounded-full bg-emerald-200 dark:bg-emerald-900 text-emerald-900 dark:text-emerald-100 text-[10px] font-bold">
                  Verified
                </span>
              </div>

              {/* Parsed Fields (Matching Screen 7 Table) */}
              <div className="rounded-2xl bg-slate-50 dark:bg-slate-800/80 p-4 border border-slate-200 dark:border-slate-700 divide-y divide-slate-200 dark:divide-slate-700 text-xs">
                <div className="py-2 flex justify-between">
                  <span className="text-slate-500">Product:</span>
                  <span className="font-bold text-slate-900 dark:text-white">{extractedData.product}</span>
                </div>

                <div className="py-2 flex justify-between">
                  <span className="text-slate-500">Purchase Date:</span>
                  <span className="font-bold text-slate-900 dark:text-white">{extractedData.purchaseDate}</span>
                </div>

                <div className="py-2 flex justify-between">
                  <span className="text-slate-500">Amount:</span>
                  <span className="font-black text-indigo-600 dark:text-indigo-400 font-['Outfit',sans-serif]">
                    ₹{extractedData.amount.toLocaleString('en-IN')}
                  </span>
                </div>

                <div className="py-2 flex justify-between">
                  <span className="text-slate-500">Seller:</span>
                  <span className="font-bold text-slate-900 dark:text-white">{extractedData.seller}</span>
                </div>

                <div className="py-2 flex justify-between">
                  <span className="text-slate-500">Invoice No.:</span>
                  <span className="font-mono font-bold text-slate-900 dark:text-white">{extractedData.invoiceNo}</span>
                </div>
              </div>

              {/* Action Buttons (Matching Screen 7 Retake vs Confirm) */}
              <div className="flex items-center space-x-2 pt-2">
                <button
                  onClick={() => setScanState('viewfinder')}
                  className="flex-1 py-3 rounded-2xl border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-300 font-bold text-xs hover:bg-slate-100 dark:hover:bg-slate-800 flex items-center justify-center space-x-1 cursor-pointer"
                >
                  <RefreshCw className="w-3.5 h-3.5" />
                  <span>Retake</span>
                </button>

                <button
                  onClick={handleConfirm}
                  className="flex-1 py-3 rounded-2xl bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white font-bold text-xs shadow-lg shadow-indigo-600/30 flex items-center justify-center space-x-1.5 cursor-pointer"
                >
                  <CheckCircle className="w-4 h-4" />
                  <span>Confirm & Save</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
