# Match Scores Page - Search by Name Filter Implementation Guide

## Overview

This guide provides the implementation details for adding a search by name filter to the match scores page in the Mujual Back Office. The route is located at `/endUsers/:userId/matchScores`.

## Architecture Context

Based on the documented architecture:
- **Framework**: React 18.1.0 with TypeScript
- **UI Library**: Material-UI (MUI) v7.1.1
- **State Management**: React Context API
- **Routing**: React Router DOM 6.3.0
- **Custom Components**: @alove component library

## Implementation Steps

### 1. Update the Match Scores Component

The match scores component should be located in the layouts directory, likely under a structure like `src/layouts/endUsers/matchScores/index.tsx`.

```tsx
// src/layouts/endUsers/matchScores/index.tsx
import React, { useState, useCallback, useMemo } from 'react';
import { useParams } from 'react-router-dom';
import { Grid, TextField, InputAdornment } from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import TablePage from 'components/alove/TablePage';
import ActionsRow from 'components/alove/ActionsRow';
import MDBox from 'components/MDBox';
import MDTypography from 'components/MDTypography';

interface MatchScore {
  id: string;
  partnerName: string;
  partnerProfileId: string;
  matchingScoreToUserPref: number;
  matchingScoreToPartnerPref: number;
  createdAt: string;
  // Add other relevant fields
}

const MatchScoresPage: React.FC = () => {
  const { userId } = useParams<{ userId: string }>();
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [matchScores, setMatchScores] = useState<MatchScore[]>([]);
  const [loading, setLoading] = useState(false);

  // Debounced search function
  const debouncedSearch = useCallback(
    debounce((query: string) => {
      // This will trigger the API call with the search parameter
      loadMatchScores(query);
    }, 300),
    [userId]
  );

  // Handle search input change
  const handleSearchChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = event.target.value;
    setSearchQuery(value);
    debouncedSearch(value);
  };

  // Load match scores with optional search filter
  const loadMatchScores = async (searchName?: string) => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (searchName?.trim()) {
        params.append('searchName', searchName.trim());
      }
      
      const response = await fetch(
        `/api/endUsers/${userId}/matchScores?${params.toString()}`
      );
      const data = await response.json();
      setMatchScores(data.results || []);
    } catch (error) {
      console.error('Error loading match scores:', error);
    } finally {
      setLoading(false);
    }
  };

  // Filter match scores based on search query (client-side backup)
  const filteredMatchScores = useMemo(() => {
    if (!searchQuery.trim()) return matchScores;
    
    return matchScores.filter(score =>
      score.partnerName?.toLowerCase().includes(searchQuery.toLowerCase())
    );
  }, [matchScores, searchQuery]);

  // Table columns configuration
  const columns = [
    {
      field: 'partnerName',
      headerName: 'Partner Name',
      width: 200,
      renderCell: (params) => (
        <MDTypography variant="body2">
          {params.value}
        </MDTypography>
      ),
    },
    {
      field: 'matchingScoreToUserPref',
      headerName: 'Score to User',
      width: 150,
      renderCell: (params) => (
        <MDTypography variant="body2">
          {params.value?.toFixed(2)}%
        </MDTypography>
      ),
    },
    {
      field: 'matchingScoreToPartnerPref',
      headerName: 'Score to Partner',
      width: 150,
      renderCell: (params) => (
        <MDTypography variant="body2">
          {params.value?.toFixed(2)}%
        </MDTypography>
      ),
    },
    {
      field: 'createdAt',
      headerName: 'Date',
      width: 150,
      renderCell: (params) => (
        <MDTypography variant="body2">
          {new Date(params.value).toLocaleDateString()}
        </MDTypography>
      ),
    },
  ];

  // Search filter component
  const SearchFilter = (
    <Grid item xs={12} md={6} lg={4}>
      <TextField
        fullWidth
        placeholder="Search by partner name..."
        value={searchQuery}
        onChange={handleSearchChange}
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <SearchIcon />
            </InputAdornment>
          ),
        }}
        variant="outlined"
        size="small"
      />
    </Grid>
  );

  return (
    <MDBox py={3}>
      <MDBox mb={3}>
        <MDTypography variant="h4" component="h1" gutterBottom>
          Match Scores for User {userId}
        </MDTypography>
      </MDBox>
      
      <TablePage
        title="Match Scores"
        table={{
          columns,
          rows: filteredMatchScores,
          loadNext: () => loadMatchScores(searchQuery),
        }}
        filters={
          <Grid container spacing={2} alignItems="center">
            {SearchFilter}
          </Grid>
        }
        loading={loading}
      />
    </MDBox>
  );
};

// Debounce utility function
function debounce(func: Function, wait: number) {
  let timeout: NodeJS.Timeout;
  return function executedFunction(...args: any[]) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

export default MatchScoresPage;
```

### 2. Update the Route Configuration

Ensure the route is properly configured in your `routes.tsx` file:

```tsx
// src/routes.tsx
import MatchScoresPage from 'layouts/endUsers/matchScores';

// In your routes configuration:
{
  type: "route",
  name: "Match Scores",
  key: "matchScores",
  route: "/endUsers/:userId/matchScores",
  component: <MatchScoresPage />,
  // Add any necessary role restrictions
}
```

### 3. Backend API Enhancement

Update your backend API endpoint to support the search parameter:

```typescript
// Backend endpoint: GET /api/endUsers/:userId/matchScores
interface MatchScoresQuery {
  searchName?: string;
  page?: number;
  limit?: number;
}

// Example API implementation
app.get('/api/endUsers/:userId/matchScores', async (req, res) => {
  const { userId } = req.params;
  const { searchName, page = 1, limit = 25 } = req.query;
  
  try {
    let query = `
      SELECT 
        ms.id,
        u.name as partner_name,
        ms.partner_profile_id,
        ms.matching_score_to_user_pref,
        ms.matching_score_to_partner_pref,
        ms.created_at
      FROM match_scores ms
      JOIN users u ON u.profile_id = ms.partner_profile_id
      WHERE ms.user_profile_id = $1
    `;
    
    const params = [userId];
    
    if (searchName) {
      query += ` AND LOWER(u.name) LIKE LOWER($${params.length + 1})`;
      params.push(`%${searchName}%`);
    }
    
    query += ` ORDER BY ms.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, (page - 1) * limit);
    
    const result = await db.query(query, params);
    
    res.json({
      results: result.rows,
      totalCount: result.rowCount,
      page: parseInt(page),
      limit: parseInt(limit)
    });
  } catch (error) {
    console.error('Error fetching match scores:', error);
    res.status(500).json({ error: 'Failed to fetch match scores' });
  }
});
```

### 4. Alternative Implementation Using @alove Components

If you want to use the existing `@alove` components more extensively:

```tsx
// Alternative implementation using AloveAutocomplete for advanced search
import AloveAutocomplete from 'components/alove/AloveAutocomplete';

// In your component:
const PartnerSearch = (
  <AloveAutocomplete
    label="Search Partners"
    placeholder="Type partner name..."
    value={searchQuery}
    onChange={(value) => {
      setSearchQuery(value);
      debouncedSearch(value);
    }}
    options={[]} // Could be populated with recent searches or suggestions
    freeSolo
    fullWidth
  />
);
```

### 5. Mobile Responsive Enhancement

For mobile responsiveness, consider using the `MobileListItem` component:

```tsx
import MobileListItem from 'components/alove/MobileListItem';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';

// In your component:
const theme = useTheme();
const isMobile = useMediaQuery(theme.breakpoints.down('md'));

// Render mobile view for small screens
if (isMobile) {
  return (
    <MDBox>
      {/* Search filter */}
      <MDBox mb={2}>
        {SearchFilter}
      </MDBox>
      
      {/* Mobile list */}
      {filteredMatchScores.map((score) => (
        <MobileListItem
          key={score.id}
          title={score.partnerName}
          subtitle={`Scores: ${score.matchingScoreToUserPref?.toFixed(1)}% / ${score.matchingScoreToPartnerPref?.toFixed(1)}%`}
          // Add other mobile-specific props
        />
      ))}
    </MDBox>
  );
}
```

## Testing Considerations

1. **Unit Tests**: Test the search functionality with various inputs
2. **Integration Tests**: Verify API integration with search parameters
3. **Performance Tests**: Ensure search doesn't impact page performance
4. **Mobile Tests**: Verify responsive behavior on different screen sizes

## Performance Optimizations

1. **Debouncing**: Implemented to reduce API calls during typing
2. **Memoization**: Used for filtering to prevent unnecessary re-renders
3. **Pagination**: Implement server-side pagination for large datasets
4. **Caching**: Consider caching recent search results

## Security Considerations

1. **Input Sanitization**: Ensure search input is properly sanitized
2. **SQL Injection Protection**: Use parameterized queries
3. **Access Control**: Verify user permissions for viewing match scores
4. **Rate Limiting**: Implement API rate limiting for search endpoints

This implementation follows the established patterns in the Mujual Back Office codebase and provides a robust, user-friendly search experience for the match scores page.