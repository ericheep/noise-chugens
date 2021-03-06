// MarkovNoise.ck
// Eric Heep

public class MarkovNoise extends Chugen {
    Markov markov;

    // default params
    6 => int range;
    1 => int order;
    1470 => int size;
    1.0 => float step;

    int chain[size];
    float transitionMatrix[0][0];
    int prevChain[size];
    float values[range];

    for (0 => int i; i < size; i++) {
        Math.random2(0, range - 1) => chain[i];
    }
    for (0 => int i; i < range; i++) {
        //(0.5/range * i + 0.25/range) => values[i];
        Math.random2f(0.0, step) => values[i];
    }

    // setters
    fun void setStep(float s) {
        s => step;
    }

    fun void setOrder(int o) {
        o => order;
    }

    fun void setRange(int r) {
        r => range => values.size;
    }

    fun void setSize(int s) {
        s => size => chain.size => prevChain.size;
    }

    fun void setChain(int st, int o, int r, int si) {
        st => step;
        o => order;
        r => range => values.size;
        si => size => chain.size => prevChain.size;
    }

    // required
    fun void calculate() {
        for (0 => int i; i < size; i++) {
            Math.random2(0, range - 1) => chain[i];
        }
        markov.generateTransitionMatrix(chain, order, range) @=> transitionMatrix;
        for (0 => int i; i < range; i++) {
            Math.random2f(0.0, step) => values[i];
        }
        markov.generateCombinations(order, range);
        markov.generateTransitionMatrix(chain, order, range) @=> transitionMatrix;
    }

    // compares chain to previous chain
    fun int similarity() {
        0 => int ratio;
        for (0 => int i; i < size; i++) {
            if (prevChain[i] == chain[i]) {
                ratio++;
            }
        }
        if (ratio/size == 1) {
            return 1;
        }
        else {
            return 0;
        }
    }

    // analyzes until redundant
    fun void analyze() {
        0 => int pos;
        0 => int flag;
        while (flag == 0) {
            (pos + 1) % size => pos;
            if (pos == 0) {
                chain @=> prevChain;
                markov.generateChain(chain, transitionMatrix, order, range) @=> chain;
                markov.generateTransitionMatrix(chain, order, range) @=> transitionMatrix;
                if(similarity()) {
                    calculate();
                };
            }
            1::samp => now;
        }
    }

    spork ~analyze();

    // reflects values back over thresholds
    fun float reflect(float in, float max, float min) {
        if (in > max) {
            return max - (in - max);
        }
        else if (in < min) {
            return min - (in - min);
        }
        else {
            return in;
        }
    }

    0 => int dir;
    0 => int tickPos;
    0.0 => float value;

    // tick, where the dsp happens
    fun float tick (float in) {
        values[chain[tickPos]] => float bump;
        (tickPos + 1) % size => tickPos;

        if (dir) {
            value + bump => value;
        }
        else {
            value - bump => value;
        }

        if (value > 1 || value < -1) {
            (dir + 1) % 2 => dir;
        }

        reflect(value, 1.0, -1.0) => value;

        return value;
    }
}

/*
MarkovNoise nois => Pan2 pan1 => dac;

nois.setStep(0.1);
nois.setRange(6);
nois.setSize(1000);
nois.setOrder(1);

nois.calculate();

1::hour => now;
*/

