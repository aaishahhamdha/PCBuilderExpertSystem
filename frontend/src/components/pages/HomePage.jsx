import { Brain, Activity, Shield, Award, Sparkles, ArrowRight } from 'lucide-react';
import { PageLayout } from '../shared/PageLayout';
import { ExpertCard } from '../shared/ExpertCard';
import { Badge } from '../shared/Badge';

export const HomePage = ({ onStart }) => {
  return (
    <PageLayout>
      <div style={{
        width: '100%',
        maxWidth: '1300px',
        minWidth: '1300px',
        margin: '0 auto',
        padding: '2rem 10rem',
        position: 'relative',
        zIndex: 1,
        display: 'flex',
        alignItems: 'center',
        minHeight: '100vh'
      }}>
        <ExpertCard maxWidth="1000px">
          <div style={{textAlign: 'center', marginBottom: '3rem'}}>
            <div style={{
              display: 'inline-flex',
              padding: '2rem',
              background: 'linear-gradient(135deg, #7c3aed 0%, #ec4899 100%)',
              borderRadius: '24px',
              marginBottom: '2rem',
              boxShadow: '0 20px 60px rgba(124, 58, 237, 0.4)'
            }}>
              <Brain style={{width: 'clamp(40px, 8vw, 64px)', height: 'clamp(40px, 8vw, 64px)', color: '#fff'}} />
            </div>
            <h1 style={{
              fontSize: 'clamp(2rem, 6vw, 3.5rem)',
              fontWeight: '800',
              color: '#fff',
              marginBottom: '1rem',
              lineHeight: '1.2'
            }}>
              PC Builder Expert
            </h1>
            <p style={{fontSize: 'clamp(1rem, 2.5vw, 1.25rem)', color: '#c4b5fd', marginBottom: '0.5rem'}}>
              AI-Powered Build Consultation
            </p>
            <p style={{fontSize: 'clamp(0.875rem, 2vw, 1rem)', color: '#9ca3af'}}>
              Let me help you build the perfect PC tailored to your needs
            </p>
          </div>

          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 180px), 1fr))',
            gap: '1rem',
            marginBottom: '3rem'
          }}>
            {[
              { icon: Activity, text: 'Hybrid Inference', color: '#3b82f6' },
              { icon: Shield, text: 'Compatibility Verified', color: '#10b981' },
              { icon: Award, text: 'Quality confidence', color: '#f59e0b' },
              { icon: Sparkles, text: 'Explainable AI', color: '#ec4899' }
            ].map((feature, i) => (
              <Badge key={i} {...feature} />
            ))}
          </div>

          <button
            onClick={onStart}
            style={{
              width: '100%',
              padding: '1.25rem',
              background: 'linear-gradient(90deg, #7c3aed 0%, #ec4899 100%)',
              color: '#fff',
              border: 'none',
              borderRadius: '16px',
              fontWeight: '700',
              fontSize: '1.125rem',
              cursor: 'pointer',
              transition: 'all 0.3s',
              boxShadow: '0 10px 30px rgba(124, 58, 237, 0.3)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '0.75rem'
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
            Start Expert Consultation
            <ArrowRight style={{width: '20px', height: '20px'}} />
          </button>
        </ExpertCard>
      </div>
    </PageLayout>
  );
};