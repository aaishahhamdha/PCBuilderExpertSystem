import React, { useState, useRef } from 'react';
import { HomePage } from './components/pages/HomePage';
import { QuestionsPage } from './components/pages/QuestionsPage';
import { GeneratingPage } from './components/pages/GeneratingPage';
import { ResultsPage } from './components/pages/ResultsPage';

const API_URL = 'http://localhost:8080/api';

const EXPERT_MESSAGES = {
  budget: "Great! Now, what budget range are you comfortable with?",
  usage: "Perfect choice! What will you primarily use this PC for?",
  gaming: "Exciting! What resolution do you want to game at?",
  cpu: "Almost there! Do you have a CPU brand preference?",
  rgb: "Nice! How important is RGB lighting to you?",
  cooling: "Finally, what's your cooling preference?"
};

export default function PCBuilderExpert() {
  const [step, setStep] = useState('welcome');
  const [inputs, setInputs] = useState({
    budget: '',
    usage: '',
    gamingLevel: '',
    cpuPreference: 'none',
    rgbImportance: 'dont_care',
    coolingPreference: 'either'
  });
  const [build, setBuild] = useState(null);
  const [originalBuild, setOriginalBuild] = useState(null);
  const [loading, setLoading] = useState(false);
  const inFlightRef = useRef(false);
  const [trace, setTrace] = useState([]);
  const [expertMessage, setExpertMessage] = useState('');
  const [chosenAlternatives, setChosenAlternatives] = useState({});

  const startConsultation = () => {
    setExpertMessage(EXPERT_MESSAGES.budget);
    setStep('budget');
  };

  const generateBuild = async (overrideInputs = null) => {
    if (inFlightRef.current) {
      console.debug('generateBuild ignored: already in flight');
      return;
    }
    inFlightRef.current = true;
    setLoading(true);
    setStep('generating');
    
    try {
      const payloadInputs = overrideInputs || inputs;
      const response = await fetch(`${API_URL}/build`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          budget: payloadInputs.budget,
          usage: payloadInputs.usage,
          gamingLevel: payloadInputs.gamingLevel || null,
          cpuPreference: payloadInputs.cpuPreference,
          rgbImportance: payloadInputs.rgbImportance,
          coolingPreference: payloadInputs.coolingPreference
        })
      });
      
      const data = await response.json();
      if (!response.ok) {
        setBuild(null);
        try {
          const traceResponse = await fetch(`${API_URL}/trace`);
          const traceData = await traceResponse.json();
          setTrace(traceData.trace || []);
        } catch (e) {}
        alert('Error generating build: ' + (data.error || 'Unknown error'));
        setStep('welcome');
        return;
      }

      setBuild(data);
      setOriginalBuild(JSON.parse(JSON.stringify(data)));
      const traceResponse = await fetch(`${API_URL}/trace`);
      const traceData = await traceResponse.json();
      setTrace(traceData.trace || []);
      setTimeout(() => setStep('result'), 1500);
    } catch (error) {
      alert('Error: ' + String(error));
      setStep('welcome');
    } finally {
      setLoading(false);
      inFlightRef.current = false;
    }
  };

  const handleNext = (field, value) => {
    if (loading || inFlightRef.current) return;

    setInputs(prev => {
      const next = { ...prev, [field]: value };
      if (field === 'coolingPreference') {
        generateBuild(next);
      }
      return next;
    });

    if (field === 'budget') {
      setExpertMessage(EXPERT_MESSAGES.usage);
      setStep('usage');
    } else if (field === 'usage') {
      if (value === 'gaming') {
        setExpertMessage(EXPERT_MESSAGES.gaming);
        setStep('gaming');
      } else {
        setExpertMessage(EXPERT_MESSAGES.cpu);
        setStep('cpu');
      }
    } else if (field === 'gamingLevel') {
      setExpertMessage(EXPERT_MESSAGES.cpu);
      setStep('cpu');
    } else if (field === 'cpuPreference') {
      setExpertMessage(EXPERT_MESSAGES.rgb);
      setStep('rgb');
    } else if (field === 'rgbImportance') {
      setExpertMessage(EXPERT_MESSAGES.cooling);
      setStep('cooling');
    }
  };

  const handleStartOver = () => {
    setStep('welcome');
    setBuild(null);
    setOriginalBuild(null);
    setInputs({ budget: '', usage: '', gamingLevel: '', cpuPreference: 'none', rgbImportance: 'dont_care', coolingPreference: 'either' });
    setChosenAlternatives({});
    setTrace([]);
  };

  if (step === 'welcome') {
    return <HomePage onStart={startConsultation} />;
  }

  if (step === 'generating') {
    return <GeneratingPage />;
  }

  if (step === 'budget' || step === 'usage' || step === 'gaming' || step === 'cpu' || step === 'rgb' || step === 'cooling') {
    return (
      <QuestionsPage
        step={step}
        inputs={inputs}
        expertMessage={expertMessage}
        onNext={handleNext}
        loading={loading}
      />
    );
  }

  if (step === 'result' && build) {
    return (
      <ResultsPage
        build={build}
        originalBuild={originalBuild}
        trace={trace}
        onStartOver={handleStartOver}
        chosenAlternatives={chosenAlternatives}
        setChosenAlternatives={setChosenAlternatives}
        setBuild={setBuild}
      />
    );
  }

  return null;
}