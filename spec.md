#Users#

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
+email: String
+password: String
+salt: String
+address: Object
+lastLogin: Date
+confirmationGuid: String
+passwordResetGuid: String
+role: String
+purchases: Array
+sales: Array
+billingDate: Date
+lastBillDate: Date
+subscriptionType: String
+cart: Object
+subscriptions: Array
+downloads: Array
+purchased: Array
+notifications: Array
+stores: Array
+sellerGuid: String
+active: Boolean
+lastCommentDate: Date
+lastGalleryDate: Date
+created: Date
+updated: Date

#Address#
Addresses are saved to user objects.  Shipping instructions are included in the address object.  They have the following schema.

##Schema##
+firstName: String
+lastName: String
+street: String
+city: String
+code: String
+country: Country
+instructions: String

#Notifications#
Notifications are an ordered list of interactions that likely require a user response.  Examples are comments between buyers and sellers, billing notices, shipping confirmations and course activations.

##Schema##
+notification: String
+read: Boolean
+created: Date
+updated: Date


#Stores#
Sellers can have multiple stores and are billed for each instance. Each store has a Quiver subdomain and an optional TLD that a seller can refer to Quiver's IP.

Stores have references to products and themes.  They display their products using the selected theme.  They also contain a list of discounts that customer may apply to a purchase.

##Schema##
+subDomain: String
+TLD: String
+products: Array
+themes: Array
+selectedTheme: Guid
+discounts: Array
+active: Boolean
+sellerGuid: String
+created: Date
+updated: Date


#Products#
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
+title: String
+description: String
+images: Array
+productType: String
+price: Number
+uri: Object
+cmsPages: Array
+duration: Integer
+startDate: Date
+endDate: EndDate
+discountValue: Number
+discountPercent: Number
+active: Boolean
+created: Date
+updated: Date

#Subscriptions#
Subscriptions are generated when a user successfully purchases a Content Subscription product.  The subscription is basically a clone of the subscription product that gets added to the user's Subscriptions array.  Any further changes to the core subscription will not change the subscription in the User's list.  Also, any future subscription purchases will attempt to add days to an existing subscription if the subscription is identical.  

Duration-based subscriptions do not start counting down their days until the subscription is first accessed, enabling the user to purchase a number of subscriptions all at once and delay actually using them. Users receive email communication two days before their subscriptions expire to remind them to finish up what they were working on.

Date-window subscriptions are active between their start and end dates.  Users should receive an email when the subscription goes live and a warning email before the subscription ends.

##Schema##
+cmsPages: Array
+startDate: Date
+endDate: Date
+duration: Number
+durationStartDate: Date
+comments: Array
+created: Date
+updated: Date

#Comments#
Comments are a single-threaded discussion between Buyer and Seller that exist on each subscription.  This enables a Buyer or a seller to discuss any particular subscription independent of gallery postings.  Buyer comments post notifications to the seller's notification stream and Seller comment post notifications back to the Buyer's notification stream.

#Gallery#
Galleries are shared between Buyers and Sellers.  They can all be accessed by the Admin, but this is a rare interaction.

Buyers post documents, whether images, video, music, text file or binaries to their galleries for review by their Seller.  Each file has a single-threaded comment stream that the Buyer and Seller can use to discuss the upload.

Notifications are generated for Buyer or Seller when the other party uploads an image or comments on a gallery post.

##Schema##
+documentTitle: String
+uri: Object
+comments: Array
+created: Date
+updated: Date

#URIs#
URIs are generated for uploaded content. Uploaded content sits behind a secure CloudFront distro that can only be accessed with the correct AWS keys.  Temporary URIs are generated via AWS and stashed for reuse until their expiration date comes within the cache buffer, at which time they must be regenerated. This prevents hotlinking of content. It also makes for short-term digital download links.

##Schema##
+resource: String
+temporaryUri: String
+uriExpirationDate: Date
+cacheBufferSeconds: Number 

#Carts#
Carts can exist in session or in the DB.  If a user cannot be found for an add-to-cart request, a cart is generated and added to session.  Upon login, any session carts are rolled into the user's regular cart; however, care must be taken to add each product through the regular channels in order to validate inventory.

##Schema##
+products: Array
+affiliateGuid: String
+sessionCart: Boolean
+discountGuid: String

#Discount#
Discounts are created by Sellers using their seller tools and by Buyers when they purchase gift certificates.  Discounts are unique to each store and exist on the store objects.

Discounts can be specific to certain products.  Discounts cannot be combined.  Combining discounts is a rat's nest, and it's not worth doing.  If Sellers want to combine discounts, they can create hybrid products and apply the combined discount to the hybrid products.

##Schema##
+value: String
+percent: String
+code: String
+description: String
+uses: Number
+maxUses: Number
+expiration: Date
+created: Date
+updated: Date

#Affiliates#
Affiliates links are created by sellers.  When a user hits the affiliate link, that user automatically gets a session cart with the appropriate affiliate GUID attached.  When that user logs in, the affiliate GUID is attached to the user's permanent cart.  Every purchase gets logged against the corresponding affiliate object if at all possible.  The owner of the affliate object can then view detailed reports on that affiliate's performance.

##Schema##

#Pages#

##Schema##
