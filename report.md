# Sine APB block

*Lowie Deferme*

## Results

Counter results are calculated as shown below:
```C
// Calculate sine
counter_start();
uint32_t sine = sin(30U);
counter_stop();
```

The sine function has the same signature (`uint32_t sin(int alpha)`) for the hardware and software implementation, this allows for easy testing by changing the included header.

The results are presented in the following table:

|             |Hardware|Software|
|------------:|--------|--------|
|Counter      |`0x12`  |`0x24`  |
|ELF text size|`652`   |`1356`  |
|Registers    |`737`   |`671`   |
|LUTs         |`1137`  |`1051`  |