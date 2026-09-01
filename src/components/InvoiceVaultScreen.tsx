import React, { useState } from 'react';
import { 
  ArrowLeft, 
  Search, 
  FileText, 
  Download, 
  Share2, 
  Plus, 
  Eye
} from 'lucide-react';
import { DocumentRecord, ProductItem } from '../types';
import { Language } from '../utils/translations';

interface InvoiceVaultScreenProps {
  documents: DocumentRecord[];
  products: ProductItem[];
  onBack: () => void;
  onOpenScanner: () => void;
  language: Language;
}

export const InvoiceVaultScreen: React.FC<InvoiceVaultScreenProps> = ({
  documents,
  products,
  onBack,
  onOpenScanner,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [viewingDoc, setViewingDoc] = useState<DocumentRecord | null>(null);

  const filteredDocs = documents.filter((d) => {
    const matchesSearch = 
      d.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      d.productName.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesSearch;
  });

  return (
    <div className="p-4 sm:p-6 space-y-4 pb-24 relative min-h-full">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <button
            onClick={onBack}
            className="p-2 rounded-2xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-200 cursor-pointer"
          >
            <ArrowLeft className="w-4 h-4" />
          </button>
          <div>
            <h1 className="text-xl font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
              Invoice Vault
            </h1>
            <p className="text-[11px] text-slate-500">{documents.length} secure documents saved</p>
          </div>
        </div>

        <button
          onClick={onOpenScanner}
          className="p-2.5 rounded-2xl bg-indigo-600 text-white font-bold text-xs shadow-md shadow-indigo-600/30 flex items-center space-x-1 cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Upload</span>
        </button>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search invoices by product or store..."
          className="w-full pl-10 pr-4 py-2.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 text-xs font-medium text-slate-900 dark:text-white shadow-xs focus:ring-2 focus:ring-indigo-500"
        />
      </div>

      {/* Invoices Grid (Matching Screen 10) */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-1">
        {filteredDocs.map((doc) => {
          const associatedProduct = products.find((p) => p.id === doc.productId);
          return (
            <div
              key={doc.id}
              className="p-4 rounded-3xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex flex-col justify-between space-y-3 hover:border-indigo-300 dark:hover:border-indigo-600 transition-colors"
            >
              <div className="flex items-start space-x-3">
                <div className="w-12 h-12 rounded-2xl bg-indigo-50 dark:bg-indigo-950/80 text-indigo-600 dark:text-indigo-400 flex items-center justify-center shrink-0 border border-indigo-100 dark:border-indigo-900/50">
                  <FileText className="w-6 h-6" />
                </div>
                <div className="space-y-0.5 flex-1 min-w-0">
                  <h4 className="text-xs font-black text-slate-900 dark:text-white truncate">
                    {doc.productName}
                  </h4>
                  <p className="text-[11px] text-slate-500 truncate">
                    {doc.name}
                  </p>
                  <div className="flex items-center space-x-2 text-[10px] text-slate-400 pt-0.5">
                    <span>{doc.uploadDate}</span>
                    <span>• {doc.size}</span>
                  </div>
                </div>
              </div>

              {associatedProduct && (
                <div className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800/80 text-[11px] flex items-center justify-between">
                  <span className="text-slate-500">Value:</span>
                  <span className="font-black text-slate-900 dark:text-white">
                    ₹{associatedProduct.purchasePrice.toLocaleString('en-IN')}
                  </span>
                </div>
              )}

              {/* Action Buttons */}
              <div className="flex items-center space-x-2 pt-1">
                <button
                  onClick={() => setViewingDoc(doc)}
                  className="flex-1 py-1.5 px-2 rounded-xl bg-indigo-50 dark:bg-indigo-950/50 text-indigo-600 dark:text-indigo-400 font-bold text-[11px] flex items-center justify-center space-x-1 hover:bg-indigo-100 cursor-pointer"
                >
                  <Eye className="w-3.5 h-3.5" />
                  <span>View</span>
                </button>
                <button
                  onClick={() => alert(`Downloading ${doc.name}`)}
                  className="p-1.5 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-200 cursor-pointer"
                  title="Download"
                >
                  <Download className="w-3.5 h-3.5" />
                </button>
                <button
                  onClick={() => alert(`Sharing document ${doc.name}`)}
                  className="p-1.5 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-200 cursor-pointer"
                  title="Share"
                >
                  <Share2 className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {/* Doc Preview Modal */}
      {viewingDoc && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-xs">
          <div className="w-full max-w-sm bg-white dark:bg-slate-900 rounded-3xl p-5 border border-slate-200 dark:border-slate-800 space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-bold text-slate-900 dark:text-white truncate">{viewingDoc.name}</h3>
              <button onClick={() => setViewingDoc(null)} className="text-slate-400 hover:text-slate-600 cursor-pointer">✕</button>
            </div>
            <div className="p-6 rounded-2xl bg-slate-100 dark:bg-slate-800 text-center space-y-2">
              <FileText className="w-12 h-12 text-indigo-500 mx-auto" />
              <p className="text-xs font-bold text-slate-800 dark:text-slate-200">Verified Invoice Document</p>
              <p className="text-[10px] text-slate-500">GST verified & backed up to encrypted Cloud Vault</p>
            </div>
            <button
              onClick={() => setViewingDoc(null)}
              className="w-full py-2.5 rounded-xl bg-indigo-600 text-white font-bold text-xs cursor-pointer"
            >
              Done
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
