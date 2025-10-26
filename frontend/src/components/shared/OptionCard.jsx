import React, { useState } from 'react';

export const OptionCard = ({ option, onClick }) => {
  const [isHovered, setIsHovered] = useState(false);
  
  return (
    <button
      onClick={onClick}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      style={{
        background: isHovered 
          ? 'linear-gradient(135deg, rgba(124, 58, 237, 0.25) 0%, rgba(236, 72, 153, 0.25) 100%)'
          : 'linear-gradient(135deg, rgba(30, 41, 59, 0.8) 0%, rgba(30, 41, 59, 0.4) 100%)',
        border: isHovered ? '2px solid rgba(124, 58, 237, 0.8)' : '2px solid rgba(71, 85, 105, 0.5)',
        borderRadius: '16px',
        padding: 'clamp(1.25rem, 3vw, 2rem)',
        cursor: 'pointer',
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        transform: isHovered ? 'translateY(-8px)' : 'translateY(0)',
        boxShadow: isHovered 
          ? '0 20px 40px rgba(124, 58, 237, 0.3)' 
          : '0 4px 12px rgba(0, 0, 0, 0.3)',
        textAlign: 'left',
        position: 'relative',
        overflow: 'hidden',
        width: '100%'
      }}
    >
      {isHovered && (
        <div style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'linear-gradient(135deg, rgba(124, 58, 237, 0.1) 0%, rgba(236, 72, 153, 0.1) 100%)',
          animation: 'shimmer 2s infinite',
          pointerEvents: 'none'
        }} />
      )}
      
      <div style={{position: 'relative', zIndex: 1}}>
        <div style={{
          fontSize: 'clamp(2.5rem, 5vw, 3rem)',
          marginBottom: '1rem',
          filter: isHovered ? 'drop-shadow(0 0 8px rgba(124, 58, 237, 0.6))' : 'none',
          transition: 'filter 0.3s'
        }}>
          {option.icon}
        </div>
        <div style={{
          fontSize: 'clamp(1.25rem, 2.5vw, 1.5rem)',
          fontWeight: '700',
          color: '#fff',
          marginBottom: '0.5rem',
          letterSpacing: '-0.01em'
        }}>
          {option.label}
        </div>
        <div style={{
          fontSize: 'clamp(0.938rem, 2vw, 1rem)',
          color: isHovered ? '#c4b5fd' : '#9ca3af',
          marginBottom: '0.75rem',
          transition: 'color 0.3s'
        }}>
          {option.desc}
        </div>
      </div>
    </button>
  );
};
