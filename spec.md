#Users#
***
There are three kinds of users:
1. Admin
2. Seller
3. Buyer

##Admin##
The main server admin has full CRUD rights to all objects; however, the admin will very rarely interact with Buyer objects.

##Seller##
Sellers pay the Admin monthly hosting fees to maintain their storefronts.  Sellers manage Buyer objects and their own site subscription.

##Buyer##
Buyers pay sellers for content. Buyers manage their own user profiles and purchases.  Buyer objects can have lists of subscriptions, downloads and purchases (physical goods) that hold copies of the actual products that they've purchased.  Sellers should modify these objects then editing purchases, whether to mark them as shipped or to extend expiration dates.

##Schema##
+ email: String
+ password: String
+ salt: String
+ address: Object
+ lastLogin: Date
+ confirmationGuid: String
+ passwordResetGuid: String
+ role: String
+ purchases: Array
+ sales: Array
+ billingDate: Date
+ lastBillDate: Date
+ subscriptionType: String
+ cart: Object
+ subscriptions: Array
+ downloads: Array
+ transactions: Array
+ notifications: Array
+ stores: Array
+ sellerGuid: String
+ isActive: Boolean
+ lastCommentDate: Date
+ lastGalleryDate: Date
+ created: Date
+ updated: Date


#Address#
***
Addresses are saved to user objects.  Shipping instructions are included in the address object.  They have the following schema.

##Schema##
+ firstName: String
+ lastName: String
+ street: String
+ city: String
+ state: String
+ code: String
+ country: Country
+ instructions: String


#Notifications#
***
Notifications are an ordered list of interactions that likely require a user response.  Examples are comments between buyers and sellers, billing notices, shipping confirmations and course activations.

##Schema##
+ notification: String
+ isRead: Boolean
+ created: Date
+ updated: Date


#Stores#
***
Sellers can have multiple stores and are billed for each instance. Each store has a Quiver subdomain and an optional TLD that a seller can refer to Quiver's IP.

Stores have references to products and themes.  They display their products using the selected theme.  They also contain a list of discounts that customer may apply to a purchase.

##Schema##
+ subDomain: String
+ TLD: String
+ products: Array
+ pages: Array
+ blogPages: Array
+ frontPage: String
+ media: Array
+ themes: Array
+ selectedTheme: Guid
+ discounts: Array
+ isActive: Boolean
+ sellerGuid: String
+ created: Date
+ updated: Date


#Products#
***
A product can be one of our types:
1. Physical good
2. Digital download
3. Content subscriptions
4. Gift certificate (coupon code)

##Physical Goods##
Physical goods have inventory levels

##Digital Downloads##
Digital downloads have limited-use URIs that are emailed to the buyer

##Content Subscriptions##
Subscriptions have an ordered list of CMS pages and either a duration or a start- and an end-date

##Schema##
+ title: String
+ description: String
+ images: Array
+ productType: String
+ price: Number
+ uri: Object
+ cmsPages: Array
+ duration: Integer
+ startDate: Date
+ endDate: EndDate
+ discountValue: Number
+ discountPercent: Number
+ isActive: Boolean
+ created: Date
+ updated: Date


#Subscriptions#
***
Subscriptions are generated when a user successfully purchases a Content Subscription product.  The subscription is basically a clone of the subscription product that gets added to the user's Subscriptions array.  Any further changes to the core subscription will not change the subscription in the User's list.  Also, any future subscription purchases will attempt to add days to an existing subscription if the subscription is identical.  

Duration-based subscriptions do not start counting down their days until the subscription is first accessed, enabling the user to purchase a number of subscriptions all at once and delay actually using them. Users receive email communication two days before their subscriptions expire to remind them to finish up what they were working on.

Date-window subscriptions are active between their start and end dates.  Users should receive an email when the subscription goes live and a warning email before the subscription ends.

##Schema##
+ cmsPages: Array
+ startDate: Date
+ endDate: Date
+ duration: Number
+ durationStartDate: Date
+ comments: Array
+ created: Date
+ updated: Date


#Comments#
***
Comments are a single-threaded discussion between Buyer and Seller that exist on each subscription.  This enables a Buyer or a seller to discuss any particular subscription independent of gallery postings.  Buyer comments post notifications to the seller's notification stream and Seller comment post notifications back to the Buyer's notification stream.

##Schema##
+ text: String
+ created: Date
+ modified: Date


#Gallery#
***
Galleries are shared between Buyers and Sellers.  They can all be accessed by the Admin, but this is a rare interaction.

Buyers post documents, whether images, video, music, text file or binaries to their galleries for review by their Seller.  Each file has a single-threaded comment stream that the Buyer and Seller can use to discuss the upload.

Notifications are generated for Buyer or Seller when the other party uploads an image or comments on a gallery post.

##Schema##
+ documentTitle: String
+ uri: Object
+ comments: Array
+ created: Date
+ updated: Date


#URIs#
***
URIs are generated for uploaded content. Uploaded content sits behind a secure CloudFront distro that can only be accessed with the correct AWS keys.  Temporary URIs are generated via AWS and stashed for reuse until their expiration date comes within the cache buffer, at which time they must be regenerated. This prevents hotlinking of content. It also makes for short-term digital download links.

##Schema##
+ resource: String
+ temporaryUri: String
+ uriExpirationDate: Date
+ cacheBufferSeconds: Number 


#Carts#
***
Carts can exist in session or in the DB.  If a user cannot be found for an add-to-cart request, a cart is generated and added to session.  Upon login, any session carts are rolled into the user's regular cart; however, care must be taken to add each product through the regular channels in order to validate inventory.

##Schema##
+ products: Array
+ affiliateGuid: String
+ isSessionCart: Boolean
+ discountGuid: String


#Discount#
***
Discounts are created by Sellers using their seller tools and by Buyers when they purchase gift certificates.  Discounts are unique to each store and exist on the store objects.

Discounts can be specific to certain products.  Discounts cannot be combined.  Combining discounts is a rat's nest, and it's not worth doing.  If Sellers want to combine discounts, they can create hybrid products and apply the combined discount to the hybrid products.

##Schema##
+ value: String
+ percent: String
+ code: String
+ description: String
+ uses: Number
+ maxUses: Number
+ expiration: Date
+ created: Date
+ updated: Date


#Affiliates#
***
Affiliates links are created by sellers.  When a user hits the affiliate link, that user automatically gets a session cart with the appropriate affiliate GUID attached.  When that user logs in, the affiliate GUID is attached to the user's permanent cart.  Every purchase gets logged against the corresponding affiliate object if at all possible.  The owner of the affliate object can then view detailed reports on that affiliate's performance.

##Schema##
+ url: String
+ transactions: Array
+ sellerGuid: String
+ created: Date
+ updated: Date


#Transactions#
***
A transaction is a snapshot of the cart with some extra values frozen in time.

##Schema##
+ products: Array
+ affiliateGuid: String
+ discountGuid: String
+ discountDollars: Number
+ total: Number
+ status: String
+ sellerGuid: String
+ created: Date


#Pages#
***
A page is markdown or HTML that can be added to content subscriptions or published as Seller blog posts. Pages belong to stores. Pages can be categorized arbitrarily for Seller organization. One page per store can be marked as that store's front page. A page can also be assigned a seller-unique slug to enable the seller to create static content.

Media files will need their own embed buttons to enable embedding within pages for all of the allowed content types without referencing any sort of public URI, because those do not exist.  The relevant URIs must be fetched at display time.

##HTML Editors##
A list of candidates
+ [https://github.com/jessegreathouse/TinyEditor]TinyEditor
+ [http://ckeditor.com/]CKEditor
+ [http://jejacks0n.github.com/mercury/]Mercury Editor
+ [http://imperavi.com/redactor/]Redactor
+ [http://ace.ajax.org/#nav=production]Ace (for raw HTML)
+ [http://oscargodson.github.com/EpicEditor/]EpicEditor (Markdown)

##Schema##
+ title: String
+ markdown: String
+ html: String
+ category: String
+ isBlogPost: Boolean
+ slug: String
+ isStaticPage: Boolean
+ isFrontPage: Boolean
+ created: Date
+ modified: Date


#Media#
***
Media is any file uploaded by a Seller for use in a page.  Media exists as part of the store object, much like pages.  Media files are uploaded to S3 and are served behind a protected CloudFront distro.  Media files require AWS signed URIs for access. They can be embedded in pages. Video files must get transcoded to mp4 and webm and downsampled if necessary to max page width.

##Schema##
+ title: String
+ description: String
+ contentType: String
