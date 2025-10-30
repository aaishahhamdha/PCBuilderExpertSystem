import { Brain } from 'lucide-react';
import { PageLayout } from '../shared/PageLayout';
import { ExpertCard } from '../shared/ExpertCard';

export const GeneratingPage = () => {
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
        <ExpertCard maxWidth="900px">
          <div style={{textAlign: 'center'}}>
            <div style={{
              display: 'inline-flex',
              padding: '2rem',
              background: 'rgba(124, 58, 237, 0.1)',
              borderRadius: '24px',
              marginBottom: '2rem',
              animation: 'pulse 2s ease-in-out infinite'
            }}>
              <Brain style={{width: 'clamp(48px, 8vw, 64px)', height: 'clamp(48px, 8vw, 64px)', color: '#7c3aed'}} />
            </div>
            <h2 style={{fontSize: 'clamp(1.5rem, 4vw, 2rem)', fontWeight: '700', color: '#fff', marginBottom: '1rem'}}>
              Analyzing Your Requirements
            </h2>
            <p style={{color: '#9ca3af', fontSize: 'clamp(1rem, 2vw, 1.125rem)', marginBottom: '3rem'}}>
              Running expert system inference...
            </p>

            <div style={{textAlign: 'left', maxWidth: '600px', margin: '0 auto'}}>
              {[
                { text: 'Forward chaining: Inferring requirements', delay: 0 },
                { text: 'Conflict resolution: Scoring candidates', delay: 0.4 },
                { text: 'Scoring & ranking: Selecting best match', delay: 0.9 },
                { text: 'Calculating quality confidence factors', delay: 0.6 }
              ].map((item, i) => (
                <div key={i} style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '1rem',
                  padding: '1rem',
                  background: 'rgba(30, 41, 59, 0.5)',
                  borderRadius: '12px',
                  marginBottom: '1rem',
                  animation: `fadeIn 0.5s ease-out ${item.delay}s both`
                }}>
                  <div style={{
                    width: '8px',
                    height: '8px',
                    background: '#7c3aed',
                    borderRadius: '50%',
                    animation: 'pulse 1.5s ease-in-out infinite',
                    flexShrink: 0
                  }} />
                  <span style={{color: '#c4b5fd', fontSize: 'clamp(0.875rem, 1.5vw, 1rem)'}}>{item.text}</span>
                </div>
              ))}
            </div>

            <div style={{
              height: '4px',
              background: 'rgba(71, 85, 105, 0.3)',
              borderRadius: '4px',
              overflow: 'hidden',
              marginTop: '1rem'
            }}>
              <div style={{
                height: '100%',
                background: 'linear-gradient(90deg, #7c3aed 0%, #ec4899 100%)',
                animation: 'progress 2s ease-in-out infinite'
              }} />
            </div>
          </div>
        </ExpertCard>
      </div>
    </PageLayout>
  );
};
