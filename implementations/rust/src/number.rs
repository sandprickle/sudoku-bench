pub struct Number(u8);

impl Number {
    fn to_u8(&self) -> u8 {
        self.0
    }

    fn from_str(str: &str) -> Option<Self> {
        match str {
            "1" => Some(Self(1)),
            "2" => Some(Self(2)),
            "3" => Some(Self(3)),
            "4" => Some(Self(4)),
            "5" => Some(Self(5)),
            "6" => Some(Self(6)),
            "7" => Some(Self(7)),
            "8" => Some(Self(8)),
            "9" => Some(Self(9)),
            _ => None,
        }
    }
}
