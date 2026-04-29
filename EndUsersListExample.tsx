// Example from End Users List Page - Search Filter Pattern
// This shows the typical pattern used in the backoffice for search filters

import React, { useState, useCallback } from 'react';
import { Grid, TextField, InputAdornment } from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import TablePage from 'components/alove/TablePage';
import MDBox from 'components/MDBox';

const EndUsersListPage: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [users, setUsers] = useState([]);

  // Debounced search - typical pattern used in the backoffice
  const debouncedSearch = useCallback(
    debounce((query: string) => {
      loadUsers(query);
    }, 300),
    []
  );

  const handleSearchChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = event.target.value;
    setSearchQuery(value);
    debouncedSearch(value);
  };

  const loadUsers = async (searchName?: string) => {
    // API call with search parameter
    const params = new URLSearchParams();
    if (searchName?.trim()) {
      params.append('searchName', searchName.trim());
    }
    
    const response = await fetch(`/api/endUsers?${params.toString()}`);
    const data = await response.json();
    setUsers(data.results || []);
  };

  // This is the search filter component pattern used across the backoffice
  const SearchFilter = (
    <Grid item xs={12} md={6} lg={4}>
      <TextField
        fullWidth
        placeholder="Search by name..."
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
      <TablePage
        title="End Users"
        table={{
          columns: [
            { field: 'name', headerName: 'Name', width: 200 },
            { field: 'email', headerName: 'Email', width: 250 },
            // ... other columns
          ],
          rows: users,
          loadNext: () => loadUsers(searchQuery),
        }}
        filters={
          <Grid container spacing={2} alignItems="center">
            {SearchFilter}
            {/* Other filters can be added here */}
          </Grid>
        }
      />
    </MDBox>
  );
};

// Utility function used throughout the backoffice
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

export default EndUsersListPage;