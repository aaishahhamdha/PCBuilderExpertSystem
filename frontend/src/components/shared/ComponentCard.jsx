import React from 'react';
import { Lightbulb, Monitor, Shield } from 'lucide-react';
import { SpecBox } from './SpecBox';

export const ComponentCard = ({ 
  componentKey, 
  label, 
  data, 
  gradient, 
  icon: Icon,
  isSelected,
  onExplain,
  onFetchAlternatives,
  chosenAlternative,
  onRevertAlternative
}) => {
  const getConfidenceColor = (conf) => {
    if (conf >= 0.9) return '#10b981';
    if (conf >= 0.8) return '#3b82f6';
    if (conf >= 0.7) return '#f59e0b';
    return '#f97316';
  };

  const renderSpecs = () => {
    switch(componentKey) {
      case 'cpu':
        return (
          <>
            <SpecBox label="Cores" value={data.cores} />
            <SpecBox label="Threads" value={data.threads} />
            <SpecBox label="Socket" value={data.socket} />
            <SpecBox label="Brand" value={data.brand} />
          </>
        );
      case 'motherboard':
        return (
          <>
            <SpecBox label="Chipset" value={data.chipset} />
            <SpecBox label="Socket" value={data.socket} />
            <SpecBox label="RAM Type" value={data.ramType.toUpperCase()} />
          </>
        );
      case 'ram':
        return (
          <>
            <SpecBox label="Capacity" value={`${data.capacity}GB`} />
            <SpecBox label="Type" value={data.type.toUpperCase()} />
            <SpecBox label="Speed" value={`${data.speed}MHz`} />
            {data.hasRGB && <SpecBox label="RGB" value={data.hasRGB === 'yes' ? 'Yes' : 'No'} />}
          </>
        );
      case 'gpu':
        return (
          <>
            <SpecBox label="Brand" value={data.brand.toUpperCase()} />
            <SpecBox label="TDP" value={`${data.tdp}W`} />
          </>
        );
      case 'storage':
        return (
          <>
            <SpecBox label="Type" value={data.type.toUpperCase()} />
            <SpecBox label="Capacity" value={`${data.capacity}GB`} />
          </>
        );
      case 'psu':
        return (
          <>
            <SpecBox label="Wattage" value={`${data.wattage}W`} />
            <SpecBox label="Efficiency" value={data.efficiency} />
          </>
        );
      case 'case':
        return (
          <>
            <SpecBox label="Form Factor" value={data.formFactor.replace('_', ' ')} />
            {data.hasRGB && <SpecBox label="RGB" value={data.hasRGB === 'yes' ? 'Yes' : 'No'} />}
            {data.aioSupport && <SpecBox label="AIO Support" value={data.aioSupport === 'yes' ? 'Yes' : 'No'} />}
          </>
        );
      default:
        return null;
    }
  };

  return (
    <div style={{
      background: 'rgba(17, 24, 39, 0.6)',
      backdropFilter: 'blur(10px)',
      borderRadius: '20px',
      padding: '2rem',
      border: isSelected ? '2px solid rgba(124, 58, 237, 0.8)' : '2px solid rgba(71, 85, 105, 0.3)',
      transition: 'all 0.3s ease',
      position: 'relative',
      overflow: 'hidden',
      boxShadow: isSelected ? '0 0 30px rgba(124, 58, 237, 0.4)' : 'none',
      transform: isSelected ? 'scale(1.02)' : 'scale(1)'
    }}>
      <div style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        height: '4px',
        background: gradient
      }} />
      
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'start',
        marginBottom: '1.5rem',
        gap: '1rem',
        flexWrap: 'wrap'
      }}>
        <div style={{display: 'flex', alignItems: 'center', gap: '1rem', flex: '1 1 0', minWidth: 0}}>
          <div style={{
            width: 'clamp(40px, 8vw, 48px)',
            height: 'clamp(40px, 8vw, 48px)',
            background: gradient,
            borderRadius: '12px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            flexShrink: 0
          }}>
            <Icon style={{width: 'clamp(20px, 4vw, 24px)', height: 'clamp(20px, 4vw, 24px)', color: '#fff'}} />
          </div>
          <div style={{minWidth: 0, flex: 1}}>
            <div style={{
              color: '#9ca3af',
              fontSize: 'clamp(0.688rem, 1.5vw, 0.75rem)',
              fontWeight: '600',
              textTransform: 'uppercase',
              letterSpacing: '0.05em',
              marginBottom: '0.25rem'
            }}>
              {label}
            </div>
            <div style={{
              color: '#fff',
              fontSize: 'clamp(1rem, 2vw, 1.125rem)',
              fontWeight: '700',
              lineHeight: '1.3',
              overflow: 'hidden',
              textOverflow: 'ellipsis'
            }}>
              {data.name}
            </div>
          </div>
        </div>
        
        <div style={{textAlign: 'right', flexShrink: 0}}>
          <div style={{fontSize: 'clamp(1.5rem, 3vw, 1.75rem)', fontWeight: '800', color: '#10b981', lineHeight: 1}}>
            ${data.price}
          </div>
          <div style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '0.25rem',
            marginTop: '0.5rem',
            padding: '0.25rem 0.75rem',
            borderRadius: '8px',
            background: `${getConfidenceColor(data.confidence)}22`,
            fontSize: 'clamp(0.688rem, 1.5vw, 0.75rem)',
            fontWeight: '600',
            color: getConfidenceColor(data.confidence)
          }}>
            <Shield style={{width: '12px', height: '12px'}} />
            {(data.confidence * 100).toFixed(0)}%
          </div>
        </div>
      </div>

      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(100px, 1fr))',
        gap: '0.75rem',
        marginBottom: '1.25rem'
      }}>
        {renderSpecs()}
      </div>

      {!chosenAlternative && (
        <button
          onClick={() => onExplain(componentKey)}
          style={{
            width: '100%',
            padding: '0.75rem',
            background: 'linear-gradient(90deg, #7c3aed 0%, #6d28d9 100%)',
            border: 'none',
            borderRadius: '10px',
            color: '#fff',
            fontWeight: '600',
            fontSize: 'clamp(0.813rem, 1.5vw, 0.875rem)',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '0.5rem',
            transition: 'all 0.2s'
          }}
          onMouseOver={(e) => e.currentTarget.style.transform = 'translateY(-2px)'}
          onMouseOut={(e) => e.currentTarget.style.transform = 'translateY(0)'}
        >
          <Lightbulb style={{width: '16px', height: '16px'}} />
          Tell Me Why
        </button>
      )}

      <button
        onClick={() => onFetchAlternatives(componentKey)}
        style={{
          marginTop: '0.75rem',
          width: '100%',
          padding: '0.75rem',
          background: 'linear-gradient(90deg, #06b6d4 0%, #0891b2 100%)',
          border: 'none',
          borderRadius: '10px',
          color: '#fff',
          fontWeight: '600',
          fontSize: 'clamp(0.813rem, 1.5vw, 0.875rem)',
          cursor: 'pointer',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '0.5rem',
          transition: 'all 0.2s'
        }}
        onMouseOver={(e) => e.currentTarget.style.transform = 'translateY(-2px)'}
        onMouseOut={(e) => e.currentTarget.style.transform = 'translateY(0)'}
      >
        <Monitor style={{width: '16px', height: '16px'}} />
        Alternatives
      </button>

      {chosenAlternative && (
        <div style={{marginTop: '0.5rem', display: 'flex', gap: '0.5rem', alignItems: 'center'}}>
          <div style={{
            padding: '0.35rem 0.6rem',
            borderRadius: '9999px',
            background: 'rgba(99,102,241,0.12)',
            color: '#8b5cf6',
            fontWeight: 700,
            fontSize: '0.812rem'
          }}>
            Using alternative
          </div>
          <button
            onClick={() => onRevertAlternative(componentKey)}
            style={{
              padding: '0.45rem 0.6rem',
              background: 'rgba(255,255,255,0.03)',
              border: '1px solid rgba(124,58,237,0.12)',
              borderRadius: '8px',
              color: '#c4b5fd',
              cursor: 'pointer',
              fontWeight: 700
            }}
          >
            Revert
          </button>
        </div>
      )}
    </div>
  );
};
