export const ExpertCard = ({ children, maxWidth = '1000px' }) => {
  const style = {
    background: 'rgba(17, 24, 39, 0.8)',
    backdropFilter: 'blur(20px)',
    borderRadius: '24px',
    padding: '2rem',
    boxShadow: '0 20px 60px rgba(0, 0, 0, 0.5), 0 0 0 1px rgba(124, 58, 237, 0.2)',
    border: '1px solid rgba(124, 58, 237, 0.1)',
    animation: 'fadeIn 0.5s ease-out',
    width: '100%',
    maxWidth
  };

  return <div style={style}>{children}</div>;
};