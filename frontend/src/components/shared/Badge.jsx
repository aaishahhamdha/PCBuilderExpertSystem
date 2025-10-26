export const Badge = ({ icon: Icon, text, color }) => (
  <div style={{
    display: 'inline-flex',
    alignItems: 'center',
    gap: '0.5rem',
    padding: '1rem',
    borderRadius: '12px',
    fontSize: 'clamp(0.75rem, 1.5vw, 0.875rem)',
    fontWeight: '600',
    background: 'rgba(124, 58, 237, 0.2)',
    color: '#c4b5fd',
    border: '1px solid rgba(124, 58, 237, 0.3)',
    justifyContent: 'center',
    flexWrap: 'wrap'
  }}>
    <Icon style={{width: '18px', height: '18px', color}} />
    <span>{text}</span>
  </div>
);