import React, { useState, useRef, useEffect } from 'react';
import { CheckCircle, Award, Activity, Sparkles, Cpu, Monitor, HardDrive, Zap, Box, MemoryStick, Disc, X, Lightbulb } from 'lucide-react';
import { PageLayout } from '../shared/PageLayout';
import { ExpertCard } from '../shared/ExpertCard';
import { ComponentCard } from '../shared/ComponentCard';

const API_URL = 'http://localhost:8080/api';

export const ResultsPage = ({ 
  build, 
  originalBuild,
  trace, 
  onStartOver,
  chosenAlternatives,
  setChosenAlternatives,
  setBuild
}) => {
  const [showTrace, setShowTrace] = useState(false);
  const [explanation, setExplanation] = useState(null);
  const [selectedComponent, setSelectedComponent] = useState(null);
  const [alternatives, setAlternatives] = useState(null);
  const [showAlternatives, setShowAlternatives] = useState(false);
  const gridRef = useRef(null);
  const [gridColumns, setGridColumns] = useState(3);

  useEffect(() => {
    const compute = () => {
      const width = gridRef.current ? gridRef.current.offsetWidth : Math.min(window.innerWidth, 1300);
      const minCol = 360;
      const gap = 24;
      const cols = Math.max(1, Math.floor((width + gap) / (minCol + gap)));
      setGridColumns(cols);
    };
    compute();
    window.addEventListener('resize', compute);
    return () => window.removeEventListener('resize', compute);
  }, []);

  const getConfidenceColor = (conf) => {
    if (conf >= 0.9) return '#10b981';
    if (conf >= 0.8) return '#3b82f6';
    if (conf >= 0.7) return '#f59e0b';
    return '#f97316';
  };

  const getConfidenceLabel = (conf) => {
    if (conf >= 0.9) return 'Excellent Match';
    if (conf >= 0.8) return 'Very Good';
    if (conf >= 0.7) return 'Good Choice';
    return 'Acceptable';
  };

  const formatExplanation = (text) => {
    if (!text || typeof text !== 'string') return { humanText: '', confidence: null };

    const confMatch = text.match(/Confidence:\s*([0-9]*\.?[0-9]+)/i);
    const confidence = confMatch ? parseFloat(confMatch[1]) : null;

    const rationaleMatch = text.match(/Selection Rationale:\s*([\s\S]*?)(?:\n|$|\u2713\sConfidence|\bConfidence:)/i);
    const rationale = rationaleMatch ? rationaleMatch[1].trim() : null;

    let humanText = '';
    const firstLine = text.split('\n')[0] || '';
    humanText += firstLine;

    if (rationale) {
      humanText += `\n\nWhy this choice:\n${rationale}`;
    } else {
      const lines = text.split(/\n+/).map(l => l.trim()).filter(Boolean);
      const filteredLines = lines.filter(l => !/\bconfidence\b/i.test(l));
      if (filteredLines.length > 1) {
        humanText += `\n\nNotes:\n- ` + filteredLines.slice(1, 4).join('\n- ');
      }
    }
    return { humanText, confidence };
  };

  const explainComponent = async (component) => {
    try {
      const response = await fetch(`${API_URL}/explain`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ component, type: 'why' })
      });
      const data = await response.json();
      if (!response.ok) return;

      const parsed = formatExplanation(data.explanation);
      setExplanation({ 
        component, 
        raw: data.explanation, 
        humanText: parsed.humanText, 
        confidence: parsed.confidence 
      });
      setSelectedComponent(component);
    } catch (error) {
      console.error('Explain error:', error);
    }
  };

  const fetchAlternatives = async (component) => {
    try {
      setAlternatives({ component, items: null, loading: true });
      setShowAlternatives(true);

      const url = `${API_URL}/alternatives?component=${encodeURIComponent(component)}`;
      const response = await fetch(url, { method: 'GET' });
      const data = await response.json();
      if (!response.ok) {
        setAlternatives({ component, items: [], error: data || { error: 'Unknown error' } });
        return;
      }

      const items = Array.isArray(data.alternatives) ? data.alternatives.map(a => ({ ...a })) : [];
      setAlternatives({ component, items });
    } catch (err) {
      setAlternatives({ component, items: [], error: String(err) });
    }
  };

  const applyChosenAlternatives = (baseBuild, chosenMap) => {
    if (!baseBuild) return null;
    const comps = ['cpu','motherboard','ram','gpu','storage','psu','case'];
    const newBuild = JSON.parse(JSON.stringify(baseBuild));

    comps.forEach((c) => {
      const alt = chosenMap[c];
      if (alt) {
        if (!newBuild[c]) newBuild[c] = {};
        Object.keys(alt).forEach(k => {
          if (k === 'price') {
            newBuild[c].price = Number(alt.price);
            return;
          }
          if (k === 'confidence') {
            if (alt.confidence != null) newBuild[c].confidence = Number(alt.confidence);
            return;
          }
          if (alt[k] != null) newBuild[c][k] = alt[k];
        });
      }
    });

    const prices = comps.map(c => (newBuild[c] && Number(newBuild[c].price)) || 0);
    const totalCost = prices.reduce((a,b) => a + b, 0);
    const confidences = comps.map(c => (newBuild[c] && newBuild[c].confidence != null) ? Number(newBuild[c].confidence) : null);
    const present = confidences.filter(c => c != null);
    const overallConfidence = present.length ? (present.reduce((a,b) => a + b, 0) / present.length) : 0;

    newBuild.totalCost = totalCost;
    newBuild.overallConfidence = overallConfidence;
    return newBuild;
  };

  const components = [
    { key: 'cpu', icon: Cpu, label: 'Processor', data: build.cpu, gradient: 'linear-gradient(135deg, #3b82f6 0%, #1e40af 100%)' },
    { key: 'ram', icon: MemoryStick, label: 'Memory', data: build.ram, gradient: 'linear-gradient(135deg, #ec4899 0%, #be185d 100%)' },
    { key: 'motherboard', icon: Box, label: 'Motherboard', data: build.motherboard, gradient: 'linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%)' },
    { key: 'gpu', icon: Monitor, label: 'Graphics Card', data: build.gpu, gradient: 'linear-gradient(135deg, #10b981 0%, #047857 100%)' },
    { key: 'storage', icon: HardDrive, label: 'Storage', data: build.storage, gradient: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)' },
    { key: 'psu', icon: Zap, label: 'Power Supply', data: build.psu, gradient: 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)' },
    { key: 'case', icon: Disc, label: 'Case', data: build.case, gradient: 'linear-gradient(135deg, #6366f1 0%, #4f46e5 100%)' }
  ];

  const visible = components.filter(c => c.data);
  const cols = gridColumns || 3;
  const remainder = visible.length % cols;
  const leading = remainder > 0 ? Math.floor((cols - remainder) / 2) : 0;
  const lastRowStart = remainder > 0 ? visible.length - remainder : visible.length;

  const renderComponents = () => {
    const items = [];
    visible.forEach((c, i) => {
      if (i === lastRowStart && leading > 0) {
        for (let p = 0; p < leading; p++) {
          items.push(<div key={`ph-${p}`} style={{ visibility: 'hidden' }} />);
        }
      }

      items.push(
        <ComponentCard
          key={c.key}
          componentKey={c.key}
          label={c.label}
          data={c.data}
          gradient={c.gradient}
          icon={c.icon}
          isSelected={selectedComponent === c.key}
          onExplain={explainComponent}
          onFetchAlternatives={fetchAlternatives}
          chosenAlternative={chosenAlternatives && chosenAlternatives[c.key]}
          onRevertAlternative={(key) => {
            const next = { ...(chosenAlternatives || {}) };
            delete next[key];
            setChosenAlternatives(next);
            if (originalBuild) {
              const preview = applyChosenAlternatives(originalBuild, next);
              setBuild(preview);
            }
          }}
        />
      );
    });
    return items;
  };

  return (
    <PageLayout>
      <div style={{
        width: '100%',
        maxWidth: '1300px',
        minWidth: '1300px',
        margin: '0 auto',
        padding: '1.5rem 10rem 2rem',
        position: 'relative',
        zIndex: 1
      }}>
        <ExpertCard>
          <div style={{display: 'flex', justifyContent: 'space-between', alignItems: 'start', flexWrap: 'wrap', gap: '2rem'}}>
            <div style={{flex: '1 1 300px', minWidth: 0}}>
              <div style={{display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '1rem', flexWrap: 'wrap'}}>
                <div style={{
                  width: 'clamp(48px, 10vw, 60px)',
                  height: 'clamp(48px, 10vw, 60px)',
                  background: 'linear-gradient(135deg, #7c3aed 0%, #ec4899 100%)',
                  borderRadius: '16px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0
                }}>
                  <CheckCircle style={{width: 'clamp(24px, 5vw, 32px)', height: 'clamp(24px, 5vw, 32px)', color: '#fff'}} />
                </div>
                <div style={{minWidth: 0}}>
                  <h1 style={{fontSize: 'clamp(1.75rem, 4vw, 2.5rem)', fontWeight: '800', color: '#fff', margin: 0, lineHeight: 1.2}}>
                    Your Perfect Build
                  </h1>
                  <p style={{color: '#9ca3af', margin: 0, marginTop: '0.25rem', fontSize: 'clamp(0.875rem, 1.5vw, 1rem)'}}>
                    Optimized by AI expert system
                  </p>
                </div>
              </div>
            </div>
            
            <div style={{textAlign: 'right', flex: '0 1 auto'}}>
              <div style={{fontSize: 'clamp(0.75rem, 1.5vw, 0.875rem)', color: '#9ca3af', marginBottom: '0.5rem'}}>
                Total Investment
              </div>
              <div style={{fontSize: 'clamp(2rem, 5vw, 3rem)', fontWeight: '800', color: '#10b981', lineHeight: 1}}>
                ${build.totalCost}
              </div>
              <div style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '0.5rem',
                padding: '0.5rem 1rem',
                borderRadius: '12px',
                fontSize: 'clamp(0.75rem, 1.5vw, 0.875rem)',
                fontWeight: '600',
                background: 'rgba(124, 58, 237, 0.2)',
                color: '#c4b5fd',
                border: '1px solid rgba(124, 58, 237, 0.3)',
                marginTop: '0.75rem'
              }}>
                <Award style={{width: '16px', height: '16px', color: getConfidenceColor(build.overallConfidence)}} />
                <span style={{color: getConfidenceColor(build.overallConfidence)}}>
                  {(build.overallConfidence * 100).toFixed(0)}% - {getConfidenceLabel(build.overallConfidence)}
                </span>
              </div>
            </div>
          </div>

          <button
            onClick={() => setShowTrace(!showTrace)}
            style={{
              marginTop: '2rem',
              padding: '0.75rem 1.5rem',
              background: 'rgba(30, 41, 59, 0.5)',
              border: '1px solid rgba(124, 58, 237, 0.3)',
              borderRadius: '12px',
              color: '#c4b5fd',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
              fontSize: 'clamp(0.813rem, 1.5vw, 0.875rem)',
              fontWeight: '500',
              transition: 'all 0.2s',
              width: '100%',
              justifyContent: 'center'
            }}
            onMouseOver={(e) => {
              e.currentTarget.style.background = 'rgba(124, 58, 237, 0.2)';
              e.currentTarget.style.borderColor = 'rgba(124, 58, 237, 0.5)';
            }}
            onMouseOut={(e) => {
              e.currentTarget.style.background = 'rgba(30, 41, 59, 0.5)';
              e.currentTarget.style.borderColor = 'rgba(124, 58, 237, 0.3)';
            }}
          >
            <Activity style={{width: '16px', height: '16px'}} />
            {showTrace ? 'Hide' : 'Show'} Reasoning Trace ({trace.length} steps)
          </button>

          {showTrace && (
            <div style={{
              marginTop: '1.5rem',
              background: 'rgba(15, 23, 42, 0.6)',
              borderRadius: '12px',
              padding: '1.5rem',
              maxHeight: '300px',
              overflowY: 'auto',
              border: '1px solid rgba(71, 85, 105, 0.3)'
            }}>
              {trace.map((t, i) => (
                <div key={i} style={{
                  fontFamily: 'ui-monospace, monospace',
                  fontSize: 'clamp(0.75rem, 1.5vw, 0.813rem)',
                  color: '#cbd5e1',
                  marginBottom: '0.75rem',
                  paddingBottom: '0.75rem',
                  borderBottom: i < trace.length - 1 ? '1px solid rgba(71, 85, 105, 0.2)' : 'none',
                  wordBreak: 'break-word'
                }}>
                  <span style={{color: '#a78bfa', fontWeight: '600'}}>[{t.type}]</span>{' '}
                  <span style={{color: '#60a5fa'}}>{t.subject}:</span>{' '}
                  {t.message}
                </div>
              ))}
            </div>
          )}
        </ExpertCard>

        <div ref={gridRef} style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 360px), 1fr))',
          gap: '1.5rem',
          marginBottom: '2rem',
          marginTop: '2rem',
          width: '100%'
        }}>
          {renderComponents()}

          {(remainder === 1 && cols > 1) && (
            <div style={{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
              <button
                onClick={onStartOver}
                style={{
                  padding: '1.25rem 1rem',
                  minHeight: '64px',
                  width: '220px',
                  background: 'linear-gradient(90deg, #7c3aed 0%, #ec4899 100%)',
                  border: 'none',
                  borderRadius: '12px',
                  color: '#fff',
                  fontWeight: '700',
                  fontSize: 'clamp(0.938rem, 2vw, 1.063rem)',
                  cursor: 'pointer',
                  transition: 'all 0.3s',
                  boxShadow: '0 10px 30px rgba(124, 58, 237, 0.3)',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.75rem',
                  justifyContent: 'center'
                }}
                onMouseOver={(e) => {
                  e.currentTarget.style.transform = 'translateY(-2px)';
                  e.currentTarget.style.boxShadow = '0 15px 40px rgba(124, 58, 237, 0.4)';
                }}
                onMouseOut={(e) => {
                  e.currentTarget.style.transform = 'translateY(0)';
                  e.currentTarget.style.boxShadow = '0 10px 30px rgba(124, 58, 237, 0.3)';
                }}
              >
                <Sparkles style={{width: '20px', height: '20px'}} />
                Build Another PC
              </button>
            </div>
          )}
        </div>

        {explanation && (
          <div 
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0, 0, 0, 0.85)',
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              zIndex: 9999,
              backdropFilter: 'blur(8px)',
              animation: 'overlayFadeIn 0.2s ease-out forwards',
              padding: '1rem'
            }}
            onClick={() => setExplanation(null)}
          >
            <div 
              style={{
                background: 'linear-gradient(135deg, rgba(31, 41, 55, 0.98) 0%, rgba(17, 24, 39, 0.98) 100%)',
                borderRadius: '1rem',
                padding: '2rem',
                width: '90%',
                maxWidth: '600px',
                position: 'relative',
                border: '1px solid rgba(124, 58, 237, 0.3)',
                boxShadow: '0 0 0 1px rgba(124, 58, 237, 0.1), 0 20px 25px -5px rgba(0, 0, 0, 0.8)',
                animation: 'modalFadeIn 0.2s ease-out forwards',
                maxHeight: '90vh',
                overflowY: 'auto'
              }}
              onClick={e => e.stopPropagation()}
            >
              <button 
                onClick={() => setExplanation(null)}
                style={{
                  position: 'absolute',
                  top: '1rem',
                  right: '1rem',
                  background: 'rgba(255, 255, 255, 0.1)',
                  border: 'none',
                  color: '#9ca3af',
                  cursor: 'pointer',
                  padding: '0.5rem',
                  borderRadius: '0.375rem',
                  transition: 'all 0.2s ease',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <X size={20} />
              </button>
              <div style={{
                display: 'flex',
                alignItems: 'flex-start',
                gap: '1.5rem',
                marginTop: '0.5rem'
              }}>
                <div style={{
                  width: '48px',
                  height: '48px',
                  borderRadius: '12px',
                  background: 'linear-gradient(135deg, #7c3aed 0%, #4c1d95 100%)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0
                }}>
                  <Lightbulb style={{width: '24px', height: '24px', color: '#fff'}} />
                </div>
                <div style={{flex: 1, minWidth: 0}}>
                  <div style={{
                    fontSize: 'clamp(1.125rem, 3vw, 1.5rem)',
                    fontWeight: '700',
                    color: '#fff',
                    marginBottom: '0.75rem',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.75rem',
                    flexWrap: 'wrap'
                  }}>
                    Why This Component?
                    <span style={{
                      padding: '0.25rem 0.75rem',
                      background: 'rgba(124, 58, 237, 0.3)',
                      borderRadius: '8px',
                      fontSize: 'clamp(0.813rem, 2vw, 0.938rem)',
                      fontWeight: '600',
                      color: '#c4b5fd',
                      textTransform: 'uppercase'
                    }}>
                      {explanation.component}
                    </span>
                  </div>
                  <div style={{
                    color: '#e5e7eb',
                    fontSize: 'clamp(0.938rem, 2vw, 1.063rem)',
                    lineHeight: '1.7',
                    letterSpacing: '0.01em',
                    whiteSpace: 'pre-wrap'
                  }}>
                    {explanation.humanText || explanation.raw}
                  </div>

                  {explanation.confidence != null && (
                    <div style={{
                      marginTop: '1rem',
                      display: 'flex',
                      justifyContent: 'flex-start'
                    }}>
                      <div style={{
                        display: 'inline-block',
                        background: 'rgba(16,185,129,0.08)',
                        padding: '0.35rem 0.6rem',
                        borderRadius: '9999px',
                        border: '1px solid rgba(16,185,129,0.14)',
                        color: '#10b981',
                        fontWeight: 600
                      }}>
                        {Math.round(explanation.confidence * 100)}% confident
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}

        {showAlternatives && alternatives && (
          <div 
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0, 0, 0, 0.85)',
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              zIndex: 9999,
              backdropFilter: 'blur(8px)',
              animation: 'overlayFadeIn 0.2s ease-out forwards',
              padding: '1rem'
            }}
            onClick={() => { setShowAlternatives(false); setAlternatives(null); }}
          >
            <div 
              style={{
                background: 'linear-gradient(135deg, rgba(31, 41, 55, 0.98) 0%, rgba(17, 24, 39, 0.98) 100%)',
                borderRadius: '1rem',
                padding: '1.25rem',
                width: '95%',
                maxWidth: '760px',
                position: 'relative',
                border: '1px solid rgba(6, 182, 212, 0.12)',
                boxShadow: '0 0 0 1px rgba(6, 182, 212, 0.06), 0 20px 25px -5px rgba(0, 0, 0, 0.8)',
                animation: 'modalFadeIn 0.2s ease-out forwards',
                maxHeight: '85vh',
                overflowY: 'auto'
              }}
              onClick={e => e.stopPropagation()}
            >
              <button 
                onClick={() => { setShowAlternatives(false); setAlternatives(null); }}
                style={{
                  position: 'absolute',
                  top: '0.75rem',
                  right: '0.75rem',
                  background: 'rgba(255, 255, 255, 0.06)',
                  border: 'none',
                  color: '#9ca3af',
                  cursor: 'pointer',
                  padding: '0.5rem',
                  borderRadius: '0.375rem',
                  transition: 'all 0.2s ease',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <X size={18} />
              </button>

              <div style={{display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '0.5rem'}}>
                <div style={{width: '44px', height: '44px', borderRadius: '10px', background: 'linear-gradient(90deg, #06b6d4, #0891b2)', display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
                  <Monitor style={{width: '22px', height: '22px', color: '#fff'}} />
                </div>
                <div>
                  <div style={{fontSize: '1.125rem', fontWeight: 800, color: '#fff'}}>Alternative Options</div>
                  <div style={{color: '#9ca3af', fontSize: '0.9rem'}}>{`Alternatives for: ${alternatives.component}`}</div>
                </div>
              </div>

              <div style={{marginTop: '0.75rem'}}>
                {alternatives.loading && (
                  <div style={{color: '#9ca3af'}}>Loading alternatives...</div>
                )}

                {alternatives.error && (
                  <div style={{color: '#f87171'}}>{String(alternatives.error?.error || alternatives.error)}</div>
                )}

                {Array.isArray(alternatives.items) && alternatives.items.length === 0 && !alternatives.loading && (
                  <div style={{color: '#9ca3af'}}>No alternatives available.</div>
                )}

                {Array.isArray(alternatives.items) && alternatives.items.length > 0 && (
                  <div style={{display: 'grid', gap: '0.75rem', marginTop: '0.75rem'}}>
                    {alternatives.items.map((alt, i) => (
                      <div key={i} style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        gap: '1rem',
                        background: 'rgba(30, 41, 59, 0.6)',
                        padding: '0.75rem',
                        borderRadius: '10px',
                        border: '1px solid rgba(71, 85, 105, 0.2)'
                      }}>
                        <div style={{minWidth: 0}}>
                          <div style={{fontWeight: 700, color: '#fff', overflow: 'hidden', textOverflow: 'ellipsis'}}>
                            {alt.name}
                          </div>
                          {alt.details && (
                            <div style={{color: '#9ca3af', fontSize: '0.875rem', marginTop: '0.25rem'}}>
                              {alt.details}
                            </div>
                          )}
                        </div>
                        <div style={{display: 'flex', alignItems: 'center', gap: '0.75rem', flexShrink: 0}}>
                          <div style={{display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '0.6rem', textAlign: 'right'}}>
                            {alt.selected && (
                              <div style={{
                                marginRight: '0.5rem',
                                display: 'inline-block',
                                padding: '0.2rem 0.5rem',
                                borderRadius: '999px',
                                background: 'rgba(124,58,237,0.12)',
                                color: '#c4b5fd',
                                fontWeight: 700,
                                fontSize: '0.75rem'
                              }}>
                                Recommended
                              </div>
                            )}
                            <div style={{fontWeight: 800, color: '#10b981'}}>${alt.price}</div>
                            <div style={{
                              fontSize: '0.813rem',
                              color: getConfidenceColor(alt.confidence),
                              fontWeight: 700
                            }}>
                              {alt.confidence != null ? `${Math.round(alt.confidence * 100)}%` : ''}
                            </div>
                          </div>
                          <button
                            onClick={() => {
                              const newChosen = { ...(chosenAlternatives || {}) };
                              const fallbackConf = (originalBuild && originalBuild[alternatives.component] && originalBuild[alternatives.component].confidence) || 0;
                              newChosen[alternatives.component] = {
                                ...alt,
                                price: Number(alt.price),
                                confidence: alt.confidence != null ? Number(alt.confidence) : fallbackConf
                              };
                              setChosenAlternatives(newChosen);
                              if (originalBuild) {
                                const preview = applyChosenAlternatives(originalBuild, newChosen);
                                setBuild(preview);
                              }
                              setShowAlternatives(false);
                              setAlternatives(null);
                            }}
                            style={{
                              padding: '0.5rem 0.75rem',
                              background: 'linear-gradient(90deg,#7c3aed,#4c1d95)',
                              color: '#fff',
                              border: 'none',
                              borderRadius: '8px',
                              cursor: 'pointer',
                              fontWeight: 700
                            }}
                          >
                            Use
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {(remainder !== 1 || cols <= 1) && (
          <div style={{display: 'flex', gap: '1rem', justifyContent: 'center', flexWrap: 'wrap'}}>
            <button
              onClick={onStartOver}
              style={{
                padding: '1.25rem 1rem',
                minHeight: '64px',
                width: '220px',
                background: 'linear-gradient(90deg, #7c3aed 0%, #ec4899 100%)',
                border: 'none',
                borderRadius: '12px',
                color: '#fff',
                fontWeight: '700',
                fontSize: 'clamp(0.938rem, 2vw, 1.063rem)',
                cursor: 'pointer',
                transition: 'all 0.3s',
                boxShadow: '0 10px 30px rgba(124, 58, 237, 0.3)',
                display: 'flex',
                alignItems: 'center',
                gap: '0.75rem',
                justifyContent: 'center',
                flex: '0 1 auto'
              }}
              onMouseOver={(e) => {
                e.currentTarget.style.transform = 'translateY(-2px)';
                e.currentTarget.style.boxShadow = '0 15px 40px rgba(124, 58, 237, 0.4)';
              }}
              onMouseOut={(e) => {
                e.currentTarget.style.transform = 'translateY(0)';
                e.currentTarget.style.boxShadow = '0 10px 30px rgba(124, 58, 237, 0.3)';
              }}
            >
              <Sparkles style={{width: '20px', height: '20px'}} />
              Build Another PC
            </button>
          </div>
        )}
      </div>
    </PageLayout>
  );
};
