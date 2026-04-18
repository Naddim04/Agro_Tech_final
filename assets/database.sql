-- SQL Schema and Queries for AgroTech App (Supabase)

-- 1. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    price NUMERIC NOT NULL,
    image_url TEXT NOT NULL,
    category TEXT NOT NULL,
    location TEXT NOT NULL,
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    rating NUMERIC DEFAULT 4.9,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for Products
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- 2. POSTS TABLE (Farm Posts / Feed)
CREATE TABLE IF NOT EXISTS public.posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT,
    user_avatar TEXT,
    content TEXT NOT NULL,
    image_url TEXT,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for Posts
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- 3. CART ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for Cart Items
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

-- STORAGE BUCKETS SETUP
-- Note: Create these buckets manually in the Supabase Dashboard
-- 1. 'product-images' (Public)
-- 2. 'post-images' (Public)

-- INDEXES for Performance
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category);
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON public.posts(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON public.cart_items(user_id);

-- POLICIES (Example for Public View)
-- Allowing anyone to select from products
CREATE POLICY "Public Products are viewable by everyone" ON public.products
    FOR SELECT USING (true);

-- Allowing anyone to select from posts
CREATE POLICY "Public Posts are viewable by everyone" ON public.posts
    FOR SELECT USING (true);
