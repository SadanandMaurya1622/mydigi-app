import React, { useState } from 'react';
import { 
  ArrowLeft, 
  Plus, 
  Clock, 
  CheckCircle2, 
  Building, 
  UserCheck 
} from 'lucide-react';
import { WarrantyClaim, ProductItem } from '../types';
import { Language } from '../utils/translations';
import confetti from 'canvas-confetti';

interface ClaimsScreenProps {
  claims: WarrantyClaim[];
  products: ProductItem[];
  onBack: () => void;
  onSelectProduct?: (product: ProductItem) => void;
  onAddClaim: (claim: WarrantyClaim) => void;
  language: Language;
}

export const ClaimsScreen: React.FC<ClaimsScreenProps> = ({
  claims,
  products,
  onBack,
  onAddClaim,
}) => {
  const [showNewClaimModal, setShowNewClaimModal] = useState(false);

  // New claim form state
  const [selectedProductId, setSelectedProductId] = useState(products[0]?.id || '');
  const [claimType, setClaimType] = useState<'Brand Warranty' | 'Extended Warranty' | 'Insurance'>('Brand Warranty');
  const [issueDescription, setIssueDescription] = useState('Cooling coil leakage and erratic compressor tripping');
  const [serviceCenter, setServiceCenter] = useState('Samsung Authorized Care, Andheri West');

  const activeClaims = claims.filter((c) => c.status !== 'Resolved' && c.status !== 'Rejected');
  const pastClaims = claims.filter((c) => c.status === 'Resolved' || c.status === 'Rejected');

  const handleCreateClaim = (e: React.FormEvent) => {
    e.preventDefault();
    const product = products.find((p) => p.id === selectedProductId) || products[0];
    const newClaim: WarrantyClaim = {
      id: `CLM-2026-${Math.floor(1000 + Math.random() * 9000)}`,
      productId: product.id,
      productName: product.name,
      ticketNumber: `TKT-${Math.floor(1000 + Math.random() * 9000)}`,
      description: issueDescription,
      claimType,
      claimDate: '2026-08-28',
      status: 'In Progress',
      issueDescription,
      serviceCenter,
      technicianAssigned: 'Vikram Joshi (+91 98222 11004)',
      trackingSteps: [
        { title: 'Claim Submitted', date: '28 Aug 2026', status: 'done' },
        { title: 'Under Review by Brand', date: '29 Aug 2026', status: 'done' },
        { title: 'Technician Assigned', date: '30 Aug 2026', status: 'done' },
        { title: 'Repair & Part Replacement', date: 'Expected 02 Sep', status: 'current' },
        { title: 'Claim Resolved', date: 'Pending', status: 'upcoming' },
      ],
    };

    confetti({ particleCount: 50, spread: 60 });
    onAddClaim(newClaim);
    setShowNewClaimModal(false);
  };

  return (
    <div className="p-4 sm:p-6 space-y-4 pb-24 relative min-h-full">
      {/* 1. Top Header */}
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
              Claims & Service
            </h1>
            <p className="text-[11px] text-slate-500">Track brand warranty claims & repair logs</p>
          </div>
        </div>

        <button
          onClick={() => setShowNewClaimModal(true)}
          className="p-2.5 rounded-2xl bg-indigo-600 text-white font-bold text-xs shadow-md shadow-indigo-600/30 flex items-center space-x-1 cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>New Claim</span>
        </button>
      </div>

      {/* 2. Active Claims (Matching Screen 11) */}
      <div className="space-y-3">
        <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
          Active Claims ({activeClaims.length})
        </span>

        {activeClaims.map((claim) => (
          <div
            key={claim.id}
            className="rounded-3xl bg-white dark:bg-slate-850 p-5 border-2 border-indigo-500/30 dark:border-indigo-500/40 shadow-lg space-y-4"
          >
            <div className="flex items-start justify-between">
              <div>
                <span className="text-[10px] font-mono font-bold text-indigo-600 dark:text-indigo-400">
                  #{claim.id}
                </span>
                <h3 className="text-base font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                  {claim.productName}
                </h3>
                <p className="text-xs text-slate-500">{claim.claimType} • Submitted on {claim.claimDate}</p>
              </div>

              <span className="px-3 py-1 rounded-full text-xs font-black bg-indigo-50 dark:bg-indigo-950/80 text-indigo-600 dark:text-indigo-400 border border-indigo-200 dark:border-indigo-800 flex items-center space-x-1">
                <span className="w-2 h-2 rounded-full bg-indigo-600 animate-ping" />
                <span>{claim.status}</span>
              </span>
            </div>

            {/* Issue summary */}
            <div className="p-3 rounded-2xl bg-slate-50 dark:bg-slate-800/80 text-xs space-y-1">
              <span className="font-bold text-slate-700 dark:text-slate-300">Reported Issue:</span>
              <p className="text-slate-600 dark:text-slate-400">{claim.issueDescription}</p>
            </div>

            {/* Service Center & Contact Info */}
            <div className="space-y-1.5 text-xs text-slate-600 dark:text-slate-400">
              <div className="flex items-center space-x-2">
                <Building className="w-3.5 h-3.5 text-indigo-500 shrink-0" />
                <span className="truncate">{claim.serviceCenter}</span>
              </div>
              {claim.technicianAssigned && (
                <div className="flex items-center space-x-2">
                  <UserCheck className="w-3.5 h-3.5 text-emerald-500 shrink-0" />
                  <span>Tech: {claim.technicianAssigned}</span>
                </div>
              )}
            </div>

            {/* Tracking Steps Timeline */}
            <div className="pt-2 border-t border-slate-100 dark:border-slate-800 space-y-2.5">
              <span className="text-[11px] font-bold text-slate-400 block uppercase tracking-wider">
                Claim Live Status Timeline
              </span>
              <div className="space-y-2">
                {claim.trackingSteps?.map((step, idx) => (
                  <div key={idx} className="flex items-start space-x-2.5">
                    <div className={`w-4 h-4 rounded-full flex items-center justify-center mt-0.5 shrink-0 ${
                      step.status === 'done'
                        ? 'bg-emerald-500 text-white' 
                        : step.status === 'current'
                        ? 'bg-indigo-500 text-white animate-pulse'
                        : 'bg-slate-200 dark:bg-slate-700 text-slate-400'
                    }`}>
                      {step.status === 'done' ? <CheckCircle2 className="w-3 h-3" /> : <Clock className="w-2.5 h-2.5" />}
                    </div>
                    <div className="flex-1 flex justify-between text-xs">
                      <span className={`font-semibold ${step.status !== 'upcoming' ? 'text-slate-900 dark:text-white' : 'text-slate-400'}`}>
                        {step.title}
                      </span>
                      <span className="text-[10px] text-slate-400">{step.date}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* 3. Past / Resolved Claims */}
      <div className="space-y-2.5 pt-2">
        <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
          Resolved History ({pastClaims.length})
        </span>

        {pastClaims.map((claim) => (
          <div
            key={claim.id}
            className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between"
          >
            <div>
              <span className="text-[10px] font-mono text-slate-400">#{claim.id}</span>
              <h4 className="text-xs sm:text-sm font-bold text-slate-900 dark:text-white">
                {claim.productName}
              </h4>
              <p className="text-[11px] text-slate-500">{claim.issueDescription}</p>
            </div>

            <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800">
              {claim.status}
            </span>
          </div>
        ))}
      </div>

      {/* New Claim Modal */}
      {showNewClaimModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-xs">
          <div className="w-full max-w-md bg-white dark:bg-slate-900 rounded-3xl p-5 border border-slate-200 dark:border-slate-800 space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b pb-3 border-slate-100 dark:border-slate-800">
              <h3 className="text-base font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                File New Warranty Claim
              </h3>
              <button onClick={() => setShowNewClaimModal(false)} className="text-slate-400 hover:text-slate-600 cursor-pointer">✕</button>
            </div>

            <form onSubmit={handleCreateClaim} className="space-y-3.5 text-xs">
              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Select Product</label>
                <select
                  value={selectedProductId}
                  onChange={(e) => setSelectedProductId(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-bold"
                >
                  {products.map((p) => (
                    <option key={p.id} value={p.id}>{p.name} ({p.brand})</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Coverage Type</label>
                <select
                  value={claimType}
                  onChange={(e) => setClaimType(e.target.value as any)}
                  className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
                >
                  <option value="Brand Warranty">Official Brand Warranty</option>
                  <option value="Extended Warranty">Extended Warranty Plan</option>
                  <option value="Insurance">Asset Insurance Policy</option>
                </select>
              </div>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Issue Description</label>
                <textarea
                  rows={3}
                  value={issueDescription}
                  onChange={(e) => setIssueDescription(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
                  required
                />
              </div>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Preferred Authorized Center</label>
                <input
                  type="text"
                  value={serviceCenter}
                  onChange={(e) => setServiceCenter(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
                />
              </div>

              <button
                type="submit"
                className="w-full py-3 rounded-2xl bg-indigo-600 text-white font-bold text-xs shadow-md shadow-indigo-600/30 cursor-pointer"
              >
                Submit Official Claim
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
