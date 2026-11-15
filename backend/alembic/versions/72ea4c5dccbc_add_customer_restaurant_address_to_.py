"""add customer restaurant address to orders

Revision ID: 72ea4c5dccbc
Revises: 7641f695f382
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '72ea4c5dccbc'
down_revision: Union[str, Sequence[str], None] = '7641f695f382'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add new columns to orders."""
    op.add_column('orders', sa.Column('customer_id', sa.Integer(), nullable=True))
    op.add_column('orders', sa.Column('restaurant_id', sa.Integer(), nullable=True))
    op.add_column('orders', sa.Column('address', sa.String(), nullable=True))
    op.add_column('orders', sa.Column('latitude', sa.Float(), nullable=True))
    op.add_column('orders', sa.Column('longitude', sa.Float(), nullable=True))
    op.add_column(
        'orders',
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=True,
        ),
    )

    # Foreign keys with explicit names (so downgrade can drop them)
    op.create_foreign_key(
        'fk_orders_customer_id_users',
        'orders', 'users',
        ['customer_id'], ['id'],
    )
    op.create_foreign_key(
        'fk_orders_restaurant_id_restaurants',
        'orders', 'restaurants',
        ['restaurant_id'], ['id'],
    )


def downgrade() -> None:
    """Remove the new columns from orders."""
    op.drop_constraint('fk_orders_restaurant_id_restaurants', 'orders', type_='foreignkey')
    op.drop_constraint('fk_orders_customer_id_users', 'orders', type_='foreignkey')

    op.drop_column('orders', 'created_at')
    op.drop_column('orders', 'longitude')
    op.drop_column('orders', 'latitude')
    op.drop_column('orders', 'address')
    op.drop_column('orders', 'restaurant_id')
    op.drop_column('orders', 'customer_id')