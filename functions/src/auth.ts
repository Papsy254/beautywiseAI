import { GoogleAuth } from 'google-auth-library';

export async function getAccessToken() {
  const auth = new GoogleAuth({
    keyFilename: 'C:/User/Downloads',  // Replace with the actual path
    scopes: 'https://www.googleapis.com/auth/cloud-platform',
  });

  try {
    const client = await auth.getClient();
    const token = await client.getAccessToken();
    return token.token;  // Return the access token to be used in requests
  } catch (error) {
    console.error('Error getting access token:', error);
    throw new Error('Failed to authenticate with Google Cloud');
  }
}
