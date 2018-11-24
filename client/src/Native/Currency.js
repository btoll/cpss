// https://hackernoon.com/creating-an-elm-native-module-for-currency-formatting-c9800e57a908

const _user$project$Native_CurrencyFormat = (() => {
    const format = num => {
        try {
            const result = num.toLocaleString('en-US',
                {
                    style: 'currency',
                    currency: 'USD'
                }
            );

            return {
                ctor: 'Ok',
                _0: result
            };
        } catch (e) {
            return {
                ctor: 'Err',
                _0: e.message
            };
        }
    };

    return {
        format
    };
})();

