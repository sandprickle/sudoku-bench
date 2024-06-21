use crate::number::Number;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct PossibleNums {
    // using lowest-order 9 bits for numbers 1-9
    bits: u16,
}

impl PossibleNums {
    /// `PossibleNums` with all numbers possible
    pub const ALL: PossibleNums = PossibleNums { bits: 0b111111111 };

    pub fn remove(&mut self, num: Number) {
        self.bits &= !(1 << (num.to_u8() - 1));
    }

    pub fn single(&self) -> Option<Number> {
        if self.bits.count_ones() == 1 {
            let mut bits = self.bits;
            let mut index = 0;
            while bits != 0 {
                if bits & 1 == 1 {
                    return Some(Number::from_u8_normalize(index + 1));
                }
                bits >>= 1;
                index += 1;
            }
        }
        None
    }

    pub fn iter(&self) -> PossibleNumsIterator {
        PossibleNumsIterator {
            bits: self.bits,
            index: 0,
        }
    }
}

impl IntoIterator for PossibleNums {
    type Item = Number;
    type IntoIter = PossibleNumsIterator;

    fn into_iter(self) -> Self::IntoIter {
        PossibleNumsIterator {
            bits: self.bits,
            index: 0,
        }
    }
}

impl IntoIterator for &PossibleNums {
    type Item = Number;
    type IntoIter = PossibleNumsIterator;

    fn into_iter(self) -> Self::IntoIter {
        self.iter()
    }
}

pub struct PossibleNumsIterator {
    bits: u16,
    index: u8,
}

impl Iterator for PossibleNumsIterator {
    type Item = Number;

    fn next(&mut self) -> Option<Self::Item> {
        while self.index < 9 {
            let mask = 1 << self.index;
            self.index += 1;
            if self.bits & mask != 0 {
                return Some(Number::from_u8_normalize(self.index));
            }
        }
        None
    }
}

#[cfg(test)]
mod tests {
    use crate::possible_nums::PossibleNumsIterator;

    use super::Number;
    use super::PossibleNums;

    #[test]
    fn remove() {
        let mut possible_nums = PossibleNums::ALL;

        possible_nums.remove(Number::One);
        assert_eq!(possible_nums.bits, 0b111111110);

        possible_nums.remove(Number::Nine);
        assert_eq!(possible_nums.bits, 0b011111110);
    }

    #[test]
    fn single() {
        let possible_nums = PossibleNums { bits: 0b000000010 };
        assert_eq!(possible_nums.single(), Some(Number::Two));

        let possible_nums = PossibleNums { bits: 0b000000000 };
        assert_eq!(possible_nums.single(), None);

        let possible_nums = PossibleNums { bits: 0b001000010 };
        assert_eq!(possible_nums.single(), None);
    }

    #[test]
    fn iterator() {
        let mut iter = PossibleNumsIterator {
            bits: 0b100111111,
            index: 0,
        };

        assert_eq!(iter.next(), Some(Number::One));
        assert_eq!(iter.next(), Some(Number::Two));
        assert_eq!(iter.next(), Some(Number::Three));
        assert_eq!(iter.next(), Some(Number::Four));
        assert_eq!(iter.next(), Some(Number::Five));
        assert_eq!(iter.next(), Some(Number::Six));
        assert_eq!(iter.next(), Some(Number::Nine));
        assert_eq!(iter.next(), None);
    }

    #[test]
    fn into_iter() {
        let possible_nums = PossibleNums { bits: 0b100000010 };

        let mut iter = possible_nums.into_iter();

        assert_eq!(iter.next(), Some(Number::Two));
        assert_eq!(iter.next(), Some(Number::Nine));
        assert_eq!(iter.next(), None);
    }

    #[test]
    fn iter() {
        let possible_nums = PossibleNums { bits: 0b100000010 };

        let mut iter = possible_nums.iter();

        assert_eq!(iter.next(), Some(Number::Two));
        assert_eq!(iter.next(), Some(Number::Nine));
        assert_eq!(iter.next(), None);
        assert_eq!(possible_nums.bits, 0b100000010)
    }
}
