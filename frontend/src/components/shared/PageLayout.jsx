export const PageLayout = ({ children }) => {
  const styles = {
    pageRoot: {
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #0a0e1a 0%, #1a1034 50%, #0a0e1a 100%)',
      position: 'relative',
      overflow: 'hidden',
      width: '100%'
    },
    bgOverlay: {
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      background: 'radial-gradient(circle at 20% 50%, rgba(124, 58, 237, 0.15) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(236, 72, 153, 0.15) 0%, transparent 50%)',
      pointerEvents: 'none'
    }
  };

  return (
    <div style={styles.pageRoot}>
      <div style={styles.bgOverlay} />
      {children}
      <style>{`
        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }
        @keyframes progress {
          0% { transform: translateX(-100%); }
          50% { transform: translateX(100%); }
          100% { transform: translateX(-100%); }
        }
        @keyframes overlayFadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes modalFadeIn {
          from { opacity: 0; transform: scale(0.95) translateY(-20px); }
          to { opacity: 1; transform: scale(1) translateY(0); }
        }
        @keyframes pulse {
          0%, 100% { opacity: 1; transform: scale(1); }
          50% { opacity: 0.7; transform: scale(0.95); }
        }
        @keyframes shimmer {
          0% { transform: translateX(-100%); }
          100% { transform: translateX(100%); }
        }
      `}</style>
    </div>
  );
};