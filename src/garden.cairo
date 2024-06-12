pub trait Summary<T> {
    fn summarize(self: @T) -> ByteArray;
}

#[derive(copy, Drop)]
pub struct NewArticle {
    pub headline: ByteArray,
    pub location: ByteArray
}

impl NewArticleSummary of Summary<NewArticle> {
    fn summarize(self: @NewArticle) -> ByteArray {
        format!("Headline :{} and location: {}", self.headline, self.location)
    }
}

fn main() {
    let news = NewArticle {
        headline: "Cairo has become the most popular language for developers",
        location: "Worldwide",
    };

    println!("New article: {}", news.summarize());
}
