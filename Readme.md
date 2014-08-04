This is a very simple Single View iOS Application, that allows the user to search for a images using the Google Image Search (Deprecated) API.

Once it search is successful application displays the images in a 3 column scrollable view. It uses a UICollectionView to implement this.

The Application also caches search history and uses UISearchBar & UISearchDisplayResultsDelegate to implement the filtered search for saved saved search history.

The Code is structured as follows:

- AppDelegate
- RootViewController (Supports CollectionView, UISearchbar (and UISearchDisplayResults))
- models
    - GImgSearchResult (holds the search result object)
    - GImgSearchResultPage (holds on to the pagination and cursor information)
    - GImgSearchFullResults (Full search results)
- services
    - GImgSearchImageCachingService (service for caching images with NSURL as the key) - wrapper for NSCache
    - GImgSearchFetchingService (Makes the Google Image Search Api call for query string, parses the responds and handles 
      pagination.
- views
    - AsyncImageView - Derived from UIImageView that allows u to load and display images from remote URL
                       Displays an activityIndicator while the image is download in the background thread
                       Once the image is downloaded it store in the cache using GImgSearchImageCachingService, and   
                       subsequent load of the view is loaded directly from the in-memory cache.
