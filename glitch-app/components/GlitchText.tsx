import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withSequence,
} from 'react-native-reanimated';

const CHARSET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
const TARGET_TEXT = 'GLITCH';
const SHUFFLE_TIME = 50; // ms

export default function GlitchText() {
  const [displayText, setDisplayText] = useState('');

  // Reanimated shared values for visual glitch
  const skewX = useSharedValue(0);
  const translateX = useSharedValue(0);

  useEffect(() => {
    let iteration = 0;

    const interval = setInterval(() => {
      setDisplayText(prev =>
        TARGET_TEXT
          .split('')
          .map((letter, index) => {
            if (index < Math.floor(iteration)) {
              return TARGET_TEXT[index];
            }
            return CHARSET[Math.floor(Math.random() * CHARSET.length)];
          })
          .join('')
      );

      if (iteration >= TARGET_TEXT.length) {
        clearInterval(interval);
        setDisplayText(TARGET_TEXT); // Ensure final state
      }

      iteration += 1 / 3; // Lock one letter every 3 cycles
    }, SHUFFLE_TIME);

    return () => clearInterval(interval);
  }, []);

  // Continuous subtle glitch animation
  useEffect(() => {
    let timeout: ReturnType<typeof setTimeout>;
    const triggerGlitch = () => {
      const duration = 100;
      translateX.value = withSequence(
        withTiming(-5, { duration: duration / 2 }),
        withTiming(5, { duration: duration / 2 }),
        withTiming(0, { duration: duration / 2 })
      );
      skewX.value = withSequence(
         withTiming(0.1, { duration: duration }),
         withTiming(-0.1, { duration: duration }),
         withTiming(0, { duration: duration })
      );

      // Randomize next glitch
      timeout = setTimeout(triggerGlitch, Math.random() * 3000 + 2000);
    };

    triggerGlitch();
    return () => clearTimeout(timeout);
  }, []);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { skewX: `${skewX.value}rad` }
    ],
  }));

  const redShiftStyle = useAnimatedStyle(() => ({
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    transform: [
      { translateX: translateX.value + 2 },
      { skewX: `${skewX.value}rad` }
    ],
    opacity: 0.7,
  }));

  const blueShiftStyle = useAnimatedStyle(() => ({
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    transform: [
      { translateX: translateX.value - 2 },
      { skewX: `${skewX.value}rad` }
    ],
    opacity: 0.7,
  }));

  return (
    <View className="relative items-center justify-center">
      <Animated.Text
        className="text-6xl font-extrabold text-[#FF00FF] absolute"
        style={redShiftStyle}
      >
        {displayText}
      </Animated.Text>
      <Animated.Text
        className="text-6xl font-extrabold text-[#00FFFF] absolute"
        style={blueShiftStyle}
      >
        {displayText}
      </Animated.Text>
      <Animated.Text
        className="text-6xl font-extrabold text-white"
        style={animatedStyle}
      >
        {displayText}
      </Animated.Text>
    </View>
  );
}
