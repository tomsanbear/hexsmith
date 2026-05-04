//! Reserved crate name for the forthcoming `hexsmith` library.
//!
//! This crate is intentionally minimal while the public API is being designed.

/// Returns the crate name.
#[must_use]
pub const fn crate_name() -> &'static str {
    "hexsmith"
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn crate_name_is_hexsmith() {
        assert_eq!(crate_name(), "hexsmith");
    }
}
