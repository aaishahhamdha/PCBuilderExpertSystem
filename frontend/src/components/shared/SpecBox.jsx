export const SpecBox = ({ label, value }) => {
  return (
    <div style={{
      background: 'rgba(30, 41, 59, 0.6)',
      borderRadius: '10px',
      padding: '0.75rem',
      border: '1px solid rgba(71, 85, 105, 0.3)'
    }}>
      <div style={{
        color: '#9ca3af',
        fontSize: 'clamp(0.625rem, 1.5vw, 0.688rem)',
        fontWeight: '600',
        textTransform: 'uppercase',
        letterSpacing: '0.05em',
        marginBottom: '0.25rem'
      }}>
        {label}
      </div>
      <div style={{
        color: '#fff',
        fontSize: 'clamp(0.875rem, 1.75vw, 0.938rem)',
        fontWeight: '700',
        wordBreak: 'break-word'
      }}>
        {value}
      </div>
    </div>
  );
};
