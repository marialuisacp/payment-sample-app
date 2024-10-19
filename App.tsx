import React from 'react';
import {
  Button,
  NativeModules,
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

  const paymentDone = (result: any) => {
    console.log('paymentDone', result);
  };

  const openPaymentMethod = async () => {
    const {PaymentModule} = NativeModules;
    PaymentModule.openPayment('10,00', paymentDone);
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
        <Button title="Pay" onPress={openPaymentMethod} />
      </ScrollView>
    </SafeAreaView>
  );
};

export default App;
