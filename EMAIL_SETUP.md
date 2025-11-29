# Email Configuration Setup

## Local Testing Setup

### Step 1: Create `.env` file

Create a `.env` file in the `food-adda-backend` directory with the following content:

```env
# Server Configuration
PORT=3001
NODE_ENV=local

# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=Rickandmorty@123
DB_NAME=foodadda

# JWT Configuration
JWT_SECRET=secret
JWT_EXPIRES_IN=24h

# Email Configuration (Gmail SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=viraldev572@gmail.com
SMTP_PASSWORD=Rickandmorty123
CONTACT_EMAIL=viraldev572@gmail.com

# Logging
LOG_LEVEL=info
```

### Step 2: Gmail Configuration

**Important**: Gmail may require an App Password instead of your regular password for SMTP access.

#### Option A: Using App Password (Recommended)

1. Go to your Google Account: https://myaccount.google.com/
2. Navigate to **Security** → **2-Step Verification** (enable it if not already enabled)
3. Go to **App passwords**: https://myaccount.google.com/apppasswords
4. Generate a new app password for "Mail" and "Other (Custom name)"
5. Name it "FoodAdda Backend"
6. Copy the 16-character password and use it in `SMTP_PASSWORD` in your `.env` file

#### Option B: Using Regular Password (May not work)

- Try using your regular password first
- If you get authentication errors, switch to Option A (App Password)

### Step 3: Test the Configuration

1. Start your backend server:

   ```bash
   cd food-adda-backend
   npm run dev
   ```

2. Test the contact form from the frontend:
   - Navigate to your homepage
   - Enter a phone number in the contact form
   - Click "Let's Connect"
   - Check your email inbox (viraldev572@gmail.com) for the contact request

### Step 4: Server Deployment

For server deployment, you need to set these environment variables on your server. The `docker-compose.yml` is already configured to read from environment variables.

#### Server Email Configuration

Set these environment variables on your server:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=sfoodadda@gmail.com
SMTP_PASSWORD=uaobmxpsjszvkwzl
CONTACT_EMAIL=sfoodadda@gmail.com
```

#### How to Set Environment Variables on Server

**Option 1: Using .env file in project root**
Create a `.env` file in the project root (same directory as `docker-compose.yml`) with:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=sfoodadda@gmail.com
SMTP_PASSWORD=uaobmxpsjszvkwzl
CONTACT_EMAIL=sfoodadda@gmail.com
```

Then Docker Compose will automatically load these when you run `docker-compose up`.

**Option 2: Export in shell before running docker-compose**

```bash
export SMTP_HOST=smtp.gmail.com
export SMTP_PORT=587
export SMTP_SECURE=false
export SMTP_USER=sfoodadda@gmail.com
export SMTP_PASSWORD=uaobmxpsjszvkwzl
export CONTACT_EMAIL=sfoodadda@gmail.com
docker-compose up -d
```

**Option 3: Set in system environment (systemd, etc.)**
If you're using systemd or another process manager, set these in your service file.

#### After Setting Variables

1. Rebuild and restart the backend container:

   ```bash
   docker-compose down
   docker-compose up -d --build backend
   ```

2. Verify the environment variables are loaded:

   ```bash
   docker-compose exec backend env | grep SMTP
   ```

3. Test the contact form on your production site and check `sfoodadda@gmail.com` for the email.

## Troubleshooting

### Authentication Error

- Make sure you're using an App Password, not your regular Gmail password
- Verify that 2-Step Verification is enabled on your Google Account

### Connection Timeout

- Check your firewall settings
- Ensure port 587 is not blocked
- Try using port 465 with `SMTP_SECURE=true` instead

### Email Not Received

- Check spam/junk folder
- Verify the `CONTACT_EMAIL` is correct
- Check backend logs for error messages
