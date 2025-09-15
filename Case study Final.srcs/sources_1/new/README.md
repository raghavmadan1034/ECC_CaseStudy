# Modular Reduction for a · b modulo P = 2^255 − 19

Let **a** and **b** be two 255-bit numbers and define their product as:

```
C = a · b
```

This is implemented using 128-bit multipliers (instead of 256-bit).

Since **C** is a 510-bit number, we represent it as the sum of six parts (each 85 bits):

```
C = C5 · 2^425 + C4 · 2^340 + C3 · 2^255 + C2 · 2^170 + C1 · 2^85 + C0
```

Here:
- `C0` = lowest 85 bits  
- `C5` = highest 85 bits  

---

### Key Observation

Since:

```
2^255 ≡ 19 (mod 2^255 − 19)
```

This implies:

```
2^255 ≡ 19
2^340 = 2^(255+85) ≡ 19 · 2^85
2^425 = 2^(255+170) ≡ 19 · 2^170
```

---

### Rewriting the Product

Using these congruences, we can rewrite the product modulo **P = 2^255 − 19** as:

```
C ≡ C0 + C1 · 2^85 + C2 · 2^170
   + C3 · 19 + C4 · 19 · 2^85 + C5 · 19 · 2^170  (mod P)
```

---

### Defining Sums

Define:

```
S0 = C0 + 19 · C3
S1 = C1 + 19 · C4
S2 = C2 + 19 · C5
```

Thus, the result becomes:

```
R ≡ S0 + S1 · 2^85 + S2 · 2^170   (mod P)
```

---

### Final Reduction

Since **R** may still be larger than **P = 2^255 − 19**,  
we must subtract **P** (possibly multiple times) to ensure the result lies in **GF(P)**.  
This can be implemented efficiently using an **FSM (Finite State Machine)**.

---

### Operations Used

This method only requires:
- Bit shifting (to multiply by powers of 2)  
- Addition  
- Subtraction  
