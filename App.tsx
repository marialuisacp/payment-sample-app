import React from 'react';
import {
  Button,
  SafeAreaView,
  ScrollView,
  StatusBar,
  Text,
  useColorScheme,
} from 'react-native';

const App = (): React.JSX.Element => {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? '#111111' : '#fefefe',
    flex: 1,
  };
  const textStyle = {
    color: isDarkMode ? '#fefefe' : '#111111',
    textAlign: 'center',
    fontSize: 20,
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <Text style={textStyle}>Payment App</Text>
        <Button title="Pay" onPress={() => console.log('Pay')} />
      </ScrollView>
    </SafeAreaView>
  );
};

export default App;
