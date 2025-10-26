import { Brain } from 'lucide-react';
import { PageLayout } from '../shared/PageLayout';
import { ExpertCard } from '../shared/ExpertCard';
import { OptionCard } from '../shared/OptionCard';

const OPTIONS = {
  budget: [
    { value: 'budget', label: 'Budget Friendly', desc: '$800 - $1,200', icon: '💰' },
    { value: 'mid_range', label: 'Mid-Range', desc: '$1,200 - $2,000', icon: '⚡' },
    { value: 'high_end', label: 'High-End', desc: '$2,000 - $3,500', icon: '🚀' },
    { value: 'enthusiast', label: 'Enthusiast', desc: '$3,500+', icon: '👑' }
  ],
  usage: [
    { value: 'office', label: 'Office Work', desc: 'Productivity & multitasking', icon: '📄' },
    { value: 'gaming', label: 'Gaming', desc: 'High-performance gaming', icon: '🎮' },
    { value: 'programming', label: 'Programming', desc: 'Development & compilation', icon: '💻' },
    { value: 'content_creation', label: 'Content Creation', desc: 'Video editing & rendering', icon: '🎨' }
  ],
  gaming: [
    { value: '1080p', label: '1080p Gaming', desc: '60-144 FPS', icon: '🎯' },
    { value: '1440p', label: '1440p Gaming', desc: '60-120 FPS', icon: '🎪' },
    { value: '4k', label: '4K Gaming', desc: '60+ FPS', icon: '🌟' }
  ],
  cpu: [
    { value: 'intel', label: 'Intel', desc: 'Prefer Intel processors', icon: '🔵' },
    { value: 'amd', label: 'AMD', desc: 'Prefer AMD processors', icon: '🔴' },
    { value: 'none', label: 'No Preference', desc: 'Best value for money', icon: '💎' }
  ],
  rgb: [
    { value: 'very_important', label: 'Very Important', desc: 'Must have RGB lighting', icon: '✨' },
    { value: 'nice_to_have', label: 'Nice to Have', desc: 'Prefer RGB if available', icon: '💡' },
    { value: 'dont_care', label: 'Don\'t Care', desc: 'RGB doesn\'t matter', icon: '⚫' }
  ],
  cooling: [
    { value: 'aio', label: 'AIO (Liquid)', desc: 'Liquid cooling preferred', icon: '💧' },
    { value: 'air', label: 'Air Cooling', desc: 'Traditional fan cooling', icon: '🌀' },
    { value: 'either', label: 'Either', desc: 'No cooling preference', icon: '🤷' }
  ]
};

export const QuestionsPage = ({ step, inputs, expertMessage, onNext, loading }) => {
  const currentOptions = OPTIONS[step] || [];
  const fieldName = step === 'gaming' ? 'gamingLevel' : 
                    step === 'cpu' ? 'cpuPreference' : 
                    step === 'rgb' ? 'rgbImportance' :
                    step === 'cooling' ? 'coolingPreference' : step;

  return (
    <PageLayout>
      <div style={{
        width: '100%',
        maxWidth: '1300px',
        minWidth: '1300px',
        margin: '0 auto',
        padding: '1.5rem 10rem',
        position: 'relative',
        zIndex: 1,
        display: 'flex',
        alignItems: 'center',
        minHeight: '100vh'
      }}>
        <ExpertCard maxWidth="1400px">
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: '1.5rem',
            marginBottom: '2rem',
            paddingBottom: '2rem',
            borderBottom: '1px solid rgba(124, 58, 237, 0.2)'
          }}>
            <div style={{
              width: '80px',
              height: '80px',
              background: 'linear-gradient(135deg, #7c3aed 0%, #ec4899 100%)',
              borderRadius: '20px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 8px 32px rgba(124, 58, 237, 0.4)'
            }}>
              <Brain style={{width: '40px', height: '40px', color: '#fff'}} />
            </div>
            <div style={{flex: 1}}>
              <div style={{fontSize: 'clamp(1.25rem, 3vw, 1.5rem)', color: '#fff', fontWeight: '500', lineHeight: '1.5'}}>
                {expertMessage}
              </div>
              <div style={{display: 'flex', gap: '0.5rem', marginTop: '1rem', flexWrap: 'wrap'}}>
                {['budget', 'usage', 'gaming', 'cpu', 'rgb', 'cooling'].map((s) => {
                  const isActive = s === step;
                  const stepOrder = ['budget', 'usage', inputs.usage === 'gaming' ? 'gaming' : '', 'cpu', 'rgb', 'cooling'];
                  const currentIndex = stepOrder.indexOf(step);
                  const sIndex = stepOrder.indexOf(s);
                  const isPast = sIndex < currentIndex && sIndex !== -1;
                  
                  return s !== '' ? (
                    <div key={s} style={{
                      flex: '1 0 auto',
                      minWidth: '40px',
                      height: '4px',
                      background: isPast || isActive ? 'linear-gradient(90deg, #7c3aed 0%, #ec4899 100%)' : 'rgba(71, 85, 105, 0.3)',
                      borderRadius: '4px',
                      opacity: isActive ? 1 : isPast ? 0.7 : 0.3
                    }} />
                  ) : null;
                })}
              </div>
            </div>
          </div>

          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 200px), 1fr))',
            gap: '1.5rem',
            marginTop: '2rem',
            width: '100%'
          }}>
            {currentOptions.map((option) => (
              <OptionCard
                key={option.value}
                option={option}
                onClick={() => !loading && onNext(fieldName, option.value)}
              />
            ))}
          </div>
        </ExpertCard>
      </div>
    </PageLayout>
  );
};