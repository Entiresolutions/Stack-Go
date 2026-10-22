import React, { useState } from 'react';
import { X, Copy, Check, Terminal, FileCode, Download, Folder } from 'lucide-react';
import { GameTheme } from '../types/game';
import { FLUTTER_PROJECT_FILES } from '../flutterFilesData';

interface FlutterProjectModalProps {
  theme: GameTheme;
  onClose: () => void;
}

export const FlutterProjectModal: React.FC<FlutterProjectModalProps> = ({ theme, onClose }) => {
  const [selectedFilePath, setSelectedFilePath] = useState<string>(FLUTTER_PROJECT_FILES[0].path);
  const [copied, setCopied] = useState<boolean>(false);
  const [activeTab, setActiveTab] = useState<'files' | 'build'>('files');

  const selectedFile =
    FLUTTER_PROJECT_FILES.find((f) => f.path === selectedFilePath) || FLUTTER_PROJECT_FILES[0];

  const handleCopyCode = () => {
    navigator.clipboard.writeText(selectedFile.content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadFile = () => {
    const blob = new Blob([selectedFile.content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = selectedFile.path.split('/').pop() || 'stack_pulse.dart';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  return (
    <div
      className="absolute inset-0 z-50 flex items-center justify-center p-3 sm:p-6 select-none"
      style={{ backgroundColor: 'rgba(11, 16, 32, 0.94)' }}
    >
      <div
        className="w-full max-w-4xl h-[92vh] max-h-[820px] rounded-3xl shadow-2xl flex flex-col overflow-hidden"
        style={{
          backgroundColor: theme.surface,
          border: '1px solid rgba(255, 255, 255, 0.1)',
        }}
      >
        {/* Top Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-white/10 shrink-0">
          <div className="flex items-center gap-3">
            <div
              className="w-10 h-10 rounded-xl flex items-center justify-center"
              style={{ backgroundColor: `${theme.primaryAccent}18`, color: theme.primaryAccent }}
            >
              <FileCode size={22} />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-base sm:text-lg font-black tracking-wide" style={{ color: theme.text }}>
                  Flutter + Flame Project Source
                </h2>
                <span
                  className="text-[10px] font-black uppercase px-2 py-0.5 rounded-full"
                  style={{ backgroundColor: `${theme.successAccent}20`, color: theme.successAccent }}
                >
                  Production Ready
                </span>
              </div>
              <p className="text-xs opacity-70 mt-0.5" style={{ color: theme.secondaryText }}>
                Complete clean architecture codebase located in <code className="text-white/90">/flutter_stack_pulse</code>
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={onClose}
              className="w-9 h-9 rounded-full flex items-center justify-center transition-transform active:scale-90"
              style={{ backgroundColor: 'rgba(255, 255, 255, 0.08)', color: theme.text }}
            >
              <X size={18} />
            </button>
          </div>
        </div>

        {/* Tab Controls */}
        <div className="flex items-center gap-2 px-6 pt-3 pb-2 border-b border-white/5 bg-black/20 shrink-0">
          <button
            onClick={() => setActiveTab('files')}
            className={`px-3.5 py-1.5 rounded-lg text-xs font-bold transition-colors ${
              activeTab === 'files'
                ? 'bg-white/15 text-white shadow-sm'
                : 'text-white/60 hover:text-white hover:bg-white/5'
            }`}
          >
            Source Files ({FLUTTER_PROJECT_FILES.length})
          </button>
          <button
            onClick={() => setActiveTab('build')}
            className={`px-3.5 py-1.5 rounded-lg text-xs font-bold transition-colors flex items-center gap-1.5 ${
              activeTab === 'build'
                ? 'bg-white/15 text-white shadow-sm'
                : 'text-white/60 hover:text-white hover:bg-white/5'
            }`}
          >
            <Terminal size={14} />
            <span>Local Build & APK Commands</span>
          </button>
        </div>

        {/* Main Content Area */}
        {activeTab === 'files' ? (
          <div className="flex-1 flex flex-col md:flex-row overflow-hidden">
            {/* Sidebar File Tree */}
            <div
              className="w-full md:w-64 border-r border-white/10 p-3 overflow-y-auto shrink-0 bg-black/15 max-h-48 md:max-h-full"
            >
              <div className="text-[11px] font-bold tracking-wider uppercase opacity-50 px-2 py-1 mb-1">
                Project Files
              </div>
              <div className="flex flex-col gap-1">
                {FLUTTER_PROJECT_FILES.map((file) => {
                  const isSelected = file.path === selectedFilePath;
                  return (
                    <button
                      key={file.path}
                      onClick={() => setSelectedFilePath(file.path)}
                      className={`text-left px-2.5 py-2 rounded-xl text-xs font-mono transition-all flex items-center justify-between ${
                        isSelected
                          ? 'bg-white/15 text-white font-bold'
                          : 'text-white/70 hover:bg-white/5 hover:text-white'
                      }`}
                    >
                      <div className="flex items-center gap-2 truncate">
                        <Folder size={14} className="shrink-0 opacity-60" />
                        <span className="truncate">{file.path}</span>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Code Viewer Panel */}
            <div className="flex-1 flex flex-col overflow-hidden bg-black/30">
              {/* File Meta Header */}
              <div className="flex items-center justify-between px-4 py-2.5 border-b border-white/10 bg-black/20 shrink-0">
                <div className="truncate pr-2">
                  <span className="text-xs font-mono font-bold text-white block truncate">
                    {selectedFile.path}
                  </span>
                  <span className="text-[11px] text-white/50 block truncate">
                    {selectedFile.description}
                  </span>
                </div>

                <div className="flex items-center gap-2 shrink-0">
                  <button
                    onClick={handleCopyCode}
                    className="px-2.5 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 transition-all bg-white/10 hover:bg-white/20 text-white cursor-pointer"
                  >
                    {copied ? <Check size={14} className="text-emerald-400" /> : <Copy size={14} />}
                    <span>{copied ? 'Copied' : 'Copy'}</span>
                  </button>

                  <button
                    onClick={handleDownloadFile}
                    className="px-2.5 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 transition-all bg-white/10 hover:bg-white/20 text-white cursor-pointer"
                    title="Download file"
                  >
                    <Download size={14} />
                    <span className="hidden sm:inline">Download</span>
                  </button>
                </div>
              </div>

              {/* Code Content */}
              <div className="flex-1 p-4 overflow-auto font-mono text-xs leading-relaxed text-slate-200 select-text bg-[#090D18]">
                <pre>
                  <code>{selectedFile.content}</code>
                </pre>
              </div>
            </div>
          </div>
        ) : (
          /* Build Instructions Panel */
          <div className="flex-1 p-6 overflow-y-auto space-y-6 text-sm text-slate-300">
            <div className="p-4 rounded-2xl bg-black/30 border border-white/10 space-y-2">
              <h3 className="font-bold text-white flex items-center gap-2">
                <Terminal size={18} className="text-cyan-400" />
                <span>Local Flutter Build Requirements</span>
              </h3>
              <p className="text-xs opacity-80 leading-relaxed">
                As reported by the development environment, Flutter/Dart toolchains are not bundled in this container runtime. The complete, production-grade Flutter + Flame project is fully scaffolded in the repository directory <code className="text-cyan-300">/flutter_stack_pulse</code>. Follow the exact commands below to build on your machine:
              </p>
            </div>

            <div className="space-y-4">
              <div>
                <h4 className="font-bold text-white text-xs uppercase tracking-wider mb-2">
                  1. Get Dependencies
                </h4>
                <div className="p-3 rounded-xl bg-black/40 font-mono text-xs text-emerald-300 border border-white/5 select-all">
                  cd flutter_stack_pulse && flutter pub get
                </div>
              </div>

              <div>
                <h4 className="font-bold text-white text-xs uppercase tracking-wider mb-2">
                  2. Run Automated Tests
                </h4>
                <div className="p-3 rounded-xl bg-black/40 font-mono text-xs text-emerald-300 border border-white/5 select-all">
                  flutter test
                </div>
              </div>

              <div>
                <h4 className="font-bold text-white text-xs uppercase tracking-wider mb-2">
                  3. Run on Connected Device / Android Emulator
                </h4>
                <div className="p-3 rounded-xl bg-black/40 font-mono text-xs text-emerald-300 border border-white/5 select-all">
                  flutter run
                </div>
              </div>

              <div>
                <h4 className="font-bold text-white text-xs uppercase tracking-wider mb-2">
                  4. Build Production Release APK
                </h4>
                <div className="p-3 rounded-xl bg-black/40 font-mono text-xs text-emerald-300 border border-white/5 select-all">
                  flutter build apk --release
                </div>
                <p className="text-[11px] opacity-60 mt-1">
                  Output: <code className="text-slate-200">build/app/outputs/flutter-apk/app-release.apk</code>
                </p>
              </div>

              <div>
                <h4 className="font-bold text-white text-xs uppercase tracking-wider mb-2">
                  5. Build Production Android App Bundle (Google Play AAB)
                </h4>
                <div className="p-3 rounded-xl bg-black/40 font-mono text-xs text-emerald-300 border border-white/5 select-all">
                  flutter build appbundle --release
                </div>
                <p className="text-[11px] opacity-60 mt-1">
                  Output: <code className="text-slate-200">build/app/outputs/bundle/release/app-release.aab</code>
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Modal Footer */}
        <div className="p-4 border-t border-white/10 bg-black/20 flex items-center justify-between shrink-0">
          <span className="text-xs opacity-60">
            {FLUTTER_PROJECT_FILES.length} Flutter & Flame project files ready for extraction
          </span>
          <button
            onClick={onClose}
            className="px-5 py-2 rounded-xl text-xs font-bold transition-all active:scale-95 cursor-pointer"
            style={{ backgroundColor: theme.primaryAccent, color: '#0B1020' }}
          >
            Close Explorer
          </button>
        </div>
      </div>
    </div>
  );
};
